import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/core/error_reporter.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';

const commit = '0123456789abcdef0123456789abcdef01234567';

void main() {
  final baseUrl = Uri.parse('https://nocsis.app');

  late List<http.Request> requests;
  late DateTime now;

  ErrorReporter reporter({
    String reportCommit = commit,
    MockClientHandler? handler,
    int maxReports = 20,
  }) => ErrorReporter(
    client: MockClient(
      handler ??
          (request) async {
            requests.add(request);
            return http.Response('', 204);
          },
    ),
    baseUrl: baseUrl,
    commit: reportCommit,
    currentPath: () => '/groups/g1/classroom',
    compiler: ClientErrorCompiler.dart2wasm,
    maxReports: maxReports,
    now: () => now,
  );

  setUp(() {
    requests = [];
    now = DateTime(2026, 11, 17);
  });

  test('エラーとスタックトレースを受け口に送る', () async {
    await reporter().report(
      StateError('壊れた'),
      StackTrace.fromString(
        'at a (main.dart.wasm:wasm-function[1]:0x10)\nat b',
      ),
    );

    expect(requests, hasLength(1));
    expect(
      requests.single.url,
      Uri.parse('https://nocsis.app/api/v1/client-errors'),
    );
    expect(
      requests.single.headers['Content-Type'],
      startsWith('application/json'),
    );
    expect(requests.single.headers['X-Client-Commit'], commit);
    expect(jsonDecode(requests.single.body), {
      'message': 'Bad state: 壊れた',
      'stack': 'at a (main.dart.wasm:wasm-function[1]:0x10)\nat b',
      'commit': commit,
      'compiler': 'dart2wasm',
      'path': '/groups/g1/classroom',
    });
  });

  test('commit が埋め込まれていないビルドでは送らない', () async {
    await reporter(reportCommit: '').report(StateError('x'), null);

    expect(requests, isEmpty);
  });

  test('長いメッセージとスタックトレースは受け口の上限で切る', () async {
    await reporter().report('a' * 3000, StackTrace.fromString('b' * 20000));

    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect((body['message'] as String).length, 2000);
    expect((body['stack'] as String).length, 16000);
  });

  test('同じエラーは 1 分のあいだ送らない', () async {
    final r = reporter();
    final stack = StackTrace.fromString('at a');

    await r.report(StateError('x'), stack);
    now = now.add(const Duration(seconds: 59));
    await r.report(StateError('x'), stack);
    expect(requests, hasLength(1));

    now = now.add(const Duration(seconds: 1));
    await r.report(StateError('x'), stack);
    expect(requests, hasLength(2));
  });

  test('1 回の起動で送るのは上限まで', () async {
    final r = reporter(maxReports: 3);

    for (var i = 0; i < 5; i++) {
      await r.report(StateError('x$i'), null);
    }

    expect(requests, hasLength(3));
  });

  test('送るのに失敗しても例外を投げない', () async {
    final r = reporter(
      handler: (_) async => throw http.ClientException('offline'),
    );

    await expectLater(r.report(StateError('x'), null), completes);
  });

  test('送れなかった分は上限に数えない', () async {
    var fail = true;
    final r = reporter(
      maxReports: 1,
      handler: (request) async {
        if (fail) {
          return http.Response('', 503);
        }
        requests.add(request);
        return http.Response('', 204);
      },
    );

    await r.report(StateError('x'), null);
    fail = false;
    await r.report(StateError('y'), null);

    expect(requests, hasLength(1));
  });

  test('メッセージやパスを作るところで失敗しても例外を投げない', () async {
    final r = ErrorReporter(
      client: MockClient((_) async => http.Response('', 204)),
      baseUrl: baseUrl,
      commit: commit,
      currentPath: () => throw StateError('path'),
    );

    await expectLater(r.report(StateError('x'), null), completes);
  });

  test('サロゲートペアの途中で切らない', () async {
    await reporter().report('a' * 1999 + '😀', null);

    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(body['message'], 'a' * 1999);
  });

  test('日本語でバイト数が受け口の上限を超えるときはスタックトレースを削る', () async {
    await reporter().report('あ' * 2000, StackTrace.fromString('い' * 16000));

    expect(requests.single.bodyBytes.length, lessThanOrEqualTo(32 * 1024));
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect((body['message'] as String).length, 2000);
  });

  test('先頭の行が同じでも、アプリのコードの行が違えば別のエラーとして送る', () async {
    final r = reporter();

    await r.report(
      StateError('x'),
      StackTrace.fromString('at runtime\nat a (main.dart.js:1:1)'),
    );
    await r.report(
      StateError('x'),
      StackTrace.fromString('at runtime\nat b (main.dart.js:2:1)'),
    );

    expect(requests, hasLength(2));
  });
}
