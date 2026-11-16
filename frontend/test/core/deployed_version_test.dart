import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/core/deployed_version.dart';

void main() {
  final base = Uri.parse('https://nocsis.app/groups/g1/classroom');

  group('fetchDeployedVersion', () {
    test('version.json の build_number を返す', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return http.Response(
          '{"app_name":"nocsis","version":"0.0.0","build_number":"42"}',
          200,
        );
      });

      expect(await fetchDeployedVersion(client, base), '42');
      expect(requested.path, '/version.json');
      expect(requested.queryParameters, contains('t'));
    });

    test('取得に失敗したら null を返す', () async {
      final client = MockClient((_) async => http.Response('', 404));

      expect(await fetchDeployedVersion(client, base), isNull);
    });

    test('通信できなければ null を返す', () async {
      final client = MockClient(
        (_) async => throw http.ClientException('offline'),
      );

      expect(await fetchDeployedVersion(client, base), isNull);
    });

    test('build_number が無ければ null を返す', () async {
      final client = MockClient(
        (_) async => http.Response('{"app_name":"nocsis"}', 200),
      );

      expect(await fetchDeployedVersion(client, base), isNull);
    });
  });

  group('NewVersionWatcher', () {
    test('デプロイされている版が違えばリロードする', () {
      fakeAsync((async) {
        var reloaded = 0;
        final watcher = NewVersionWatcher(
          current: '1',
          fetchDeployed: () async => '2',
          reload: () => reloaded++,
          interval: const Duration(minutes: 5),
        )..start();

        async.elapse(const Duration(minutes: 4));
        expect(reloaded, 0);

        async.elapse(const Duration(minutes: 1));
        expect(reloaded, 1);

        // リロードした後は見張りをやめる
        async.elapse(const Duration(minutes: 10));
        expect(reloaded, 1);
        watcher.stop();
      });
    });

    test('同じ版ならリロードしない', () {
      fakeAsync((async) {
        var reloaded = 0;
        final watcher = NewVersionWatcher(
          current: '1',
          fetchDeployed: () async => '1',
          reload: () => reloaded++,
        )..start();

        async.elapse(const Duration(minutes: 30));
        expect(reloaded, 0);
        watcher.stop();
      });
    });

    test('版が読めなければリロードしない', () {
      fakeAsync((async) {
        var reloaded = 0;
        final watcher = NewVersionWatcher(
          current: '1',
          fetchDeployed: () async => null,
          reload: () => reloaded++,
        )..start();

        async.elapse(const Duration(minutes: 30));
        expect(reloaded, 0);
        watcher.stop();
      });
    });

    test('自分の版が埋め込まれていなければ見張らない', () {
      fakeAsync((async) {
        var fetched = 0;
        final watcher = NewVersionWatcher(
          current: '',
          fetchDeployed: () async {
            fetched++;
            return '2';
          },
          reload: () {},
        )..start();

        async.elapse(const Duration(minutes: 30));
        expect(fetched, 0);
        watcher.stop();
      });
    });

    test('止めた後に返ってきた結果ではリロードしない', () {
      fakeAsync((async) {
        var reloaded = 0;
        final watcher = NewVersionWatcher(
          current: '1',
          fetchDeployed: () =>
              Future.delayed(const Duration(seconds: 10), () => '2'),
          reload: () => reloaded++,
        )..start();

        async.elapse(const Duration(minutes: 5));
        watcher.stop();
        async.elapse(const Duration(seconds: 10));

        expect(reloaded, 0);
      });
    });
  });
}
