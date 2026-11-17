import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// ビルドした commit。`flutter run` など、CI 以外のビルドでは空。
const buildCommit = String.fromEnvironment('BUILD_COMMIT');

const _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

/// 起きたエラーを backend の受け口に送る。
///
/// 送るのに失敗しても何もしない。エラーの報告でアプリを止めたり、
/// 報告の失敗をまた報告したりしないため。
class ErrorReporter {
  ErrorReporter({
    required this.client,
    required this.endpoint,
    required this.commit,
    required this.currentPath,
    this.compiler = _isWasm ? 'dart2wasm' : 'dart2js',
    this.maxReports = 20,
    this.duplicateWindow = const Duration(minutes: 1),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final http.Client client;
  final Uri endpoint;
  final String commit;
  final String Function() currentPath;
  final String compiler;

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

    final message = _truncate(error.toString(), 2000);
    final stackText = _truncate(stack?.toString() ?? '', 16000);

    final key = '$message\n${stackText.split('\n').first}';
    final now = _now();
    final last = _lastSentAt[key];
    if (last != null && now.difference(last) < duplicateWindow) {
      return;
    }
    _lastSentAt[key] = now;
    _sent++;

    try {
      await client
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'stack': stackText,
              'commit': commit,
              'compiler': compiler,
              'path': _truncate(currentPath(), 200),
            }),
          )
          .timeout(const Duration(seconds: 10));
    } on Object {
      // 送れなくても、画面の動作には関係ない
    }
  }
}

String _truncate(String text, int max) =>
    text.length <= max ? text : text.substring(0, max);
