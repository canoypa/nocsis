import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/core/client_commit.dart';

const commit = '0123456789abcdef0123456789abcdef01234567';

void main() {
  late List<http.Request> requests;

  Api api(String commit) => Api.create(
    baseUrl: Uri.parse('https://nocsis.app'),
    httpClient: MockClient((request) async {
      requests.add(request);
      return http.Response('{"groups":[]}', 200);
    }),
    interceptors: [clientCommitInterceptor(commit)],
  );

  setUp(() => requests = []);

  group('clientCommitInterceptor', () {
    test('ビルドした commit をヘッダーに付ける', () async {
      await api(commit).apiV1UsersMeGroupsGet();

      expect(requests.single.headers['X-Client-Commit'], commit);
    });

    test('commit が空のビルドではヘッダーを付けない', () async {
      await api('').apiV1UsersMeGroupsGet();

      expect(requests.single.headers.containsKey('X-Client-Commit'), isFalse);
    });
  });
}
