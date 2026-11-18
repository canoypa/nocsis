import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nocsis/core/client_commit.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';

const _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

// 受け口のスキーマとリクエストの上限に合わせる。超えると 400 / 413 で捨てられる。
const _maxMessageLength = 2000;
const _maxStackLength = 16000;
const _maxPathLength = 200;
const _maxBodyBytes = 32 * 1024;

/// 起きたエラーを backend の受け口に送る。
///
/// 送るのに失敗しても何もしない。エラーの報告でアプリを止めたり、
/// 報告の失敗をまた報告したりしないため。
class ErrorReporter {
  ErrorReporter({
    required http.Client client,
    required Uri baseUrl,
    required this.commit,
    required this.currentPath,
    this.compiler = _isWasm
        ? ClientErrorCompiler.dart2wasm
        : ClientErrorCompiler.dart2js,
    this.maxReports = 20,
    this.duplicateWindow = const Duration(minutes: 1),
    DateTime Function()? now,
  }) : _api = Api.create(
         baseUrl: baseUrl,
         httpClient: client,
         interceptors: [clientCommitInterceptor(commit)],
       ),
       _now = now ?? DateTime.now;

  // 認証の interceptor は付けない。ログイン前や認証まわりで起きたエラーも送るため
  final Api _api;
  final String commit;
  final String Function() currentPath;
  final ClientErrorCompiler compiler;

  /// 1 回の起動で送る上限。壊れた画面が毎フレーム同じエラーを出しても送り続けない
  final int maxReports;

  /// 同じエラーをこの間は送らない
  final Duration duplicateWindow;

  final DateTime Function() _now;
  final _lastSentAt = <String, DateTime>{};
  int _sent = 0;

  /// [error] を送る。待たなくてよい。
  Future<void> report(Object error, StackTrace? stack) async {
    // どの版のソースマップで解読すればよいか分からないので、送っても読めない
    if (commit.isEmpty || _sent >= maxReports) {
      return;
    }

    var counted = false;
    try {
      final message = _truncate(error.toString(), _maxMessageLength);
      var stackText = _truncate(stack?.toString() ?? '', _maxStackLength);

      final key = '$message\n${_firstAppFrame(stackText)}';
      final now = _now();
      final last = _lastSentAt[key];
      if (last != null && now.difference(last) < duplicateWindow) {
        return;
      }
      _lastSentAt[key] = now;

      ClientError body() => ClientError(
        message: message,
        stack: stackText,
        commit: commit,
        compiler: compiler,
        path: _truncate(currentPath(), _maxPathLength),
      );
      // 文字数の上限に収めても、日本語などで UTF-8 のバイト数が上限を超えうる。
      // 1 文字は 1 バイト以上なので、超えた分の文字数を削れば必ず縮む。
      for (
        var excess = _bodyBytes(body()) - _maxBodyBytes;
        excess > 0 && stackText.isNotEmpty;
        excess = _bodyBytes(body()) - _maxBodyBytes
      ) {
        stackText = _truncate(
          stackText,
          (stackText.length - excess).clamp(0, stackText.length),
        );
      }

      _sent++;
      counted = true;
      final response = await _api
          .apiV1ClientErrorsPost(body: body())
          .timeout(const Duration(seconds: 10));
      if (!response.isSuccessful) {
        _sent--;
      }
    } on Object {
      // 送れなくても、画面の動作には関係ない。送れなかった分は上限に数えない
      if (counted) {
        _sent--;
      }
    }
  }
}

int _bodyBytes(ClientError body) =>
    utf8.encode(jsonEncode(body.toJson())).length;

/// 重複の判定に使う、アプリのコードの最初の行。
/// 先頭はブラウザやランタイムの行のことがあり、別のエラーでも同じになる
String _firstAppFrame(String stack) {
  final lines = stack.split('\n');
  return lines.firstWhere(
    (l) => l.contains('main.dart'),
    orElse: () => lines.first,
  );
}

/// サロゲートペアの途中で切らない
String _truncate(String text, int max) {
  if (text.length <= max) {
    return text;
  }
  final end = max > 0 && _isHighSurrogate(text.codeUnitAt(max - 1))
      ? max - 1
      : max;
  return text.substring(0, end);
}

bool _isHighSurrogate(int codeUnit) => codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
