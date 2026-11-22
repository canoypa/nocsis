import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/core/route_access.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/routes/router.dart';

/// 末端の GoRoute のパスを全部集める。子のパスが相対なら親のパスに足す
List<String> leafPaths(List<RouteBase> routes, [String parent = '']) => [
  for (final route in routes)
    ...switch (route) {
      GoRoute(:final path, :final routes) => () {
        final full = path.startsWith('/')
            ? path
            : '${parent == '/' ? '' : parent}/$path';
        return [full, ...leafPaths(routes, full)];
      }(),
      ShellRouteBase(:final routes) => leafPaths(routes, parent),
      _ => throw UnsupportedError('未知のルート: $route'),
    },
];

void main() {
  test('すべてのルートが、自分か祖先に宣言を持っている', () {
    final paths = leafPaths($appRoutes);

    // 列挙が空なら検査が素通りする
    expect(paths, isNotEmpty);
    expect(paths.where((path) => declarationsFor(path).isEmpty), isEmpty);
  });

  test('宣言の無いパスは開けず、公開でもない', () {
    expect(declarationsFor('/admin'), isEmpty);
    expect(canOpen('/admin', Permission.values.toSet()), isFalse);
    expect(isPublic('/admin'), isFalse);
  });

  test('祖先の宣言を受け継ぐ', () {
    expect(declarationsFor('/groups/:groupId/events'), [
      isA<GroupAccess>().having((d) => d.anyOf, 'anyOf', {
        Permission.groupRead,
      }),
    ]);
  });

  test('子は親の宣言に条件を足す（祖先の宣言もすべて満たす必要がある）', () {
    // console/day_duty は group.update だけを要るが、/groups/:groupId の group.read も要る
    expect(
      canOpen('/groups/:groupId/console/day_duty', {Permission.groupUpdate}),
      isFalse,
    );
    expect(
      canOpen('/groups/:groupId/console/day_duty', {
        Permission.groupRead,
        Permission.groupUpdate,
      }),
      isTrue,
    );
  });

  test('ログインの要否', () {
    expect(isPublic(LoginPageRoute.path), isTrue);
    expect(isPublic(TopPageRoute.path), isFalse);
    expect(isPublic('/groups/:groupId'), isFalse);
    expect(isPublic('/licenses'), isTrue);
  });

  group('ロールごとに開けるグループの画面', () {
    // backend の roles.ts と同じ束。ロールを変えたらここも見直す
    const viewer = {Permission.groupRead};
    const display = {Permission.groupRead, Permission.memberRead};
    final admin = Permission.values.toSet();

    final groupPaths = leafPaths($appRoutes)
        .where((path) => needsGroupPermissions(path));
    bool isConsole(String path) => path.startsWith('/groups/:groupId/console');

    test('閲覧だけ: コンソールと教室の画面以外', () {
      for (final path in groupPaths) {
        expect(
          canOpen(path, viewer),
          !isConsole(path) && path != '/groups/:groupId/classroom',
          reason: path,
        );
      }
    });

    test('教室の表示端末: コンソール以外', () {
      for (final path in groupPaths) {
        expect(canOpen(path, display), !isConsole(path), reason: path);
      }
    });

    test('admin: すべて', () {
      for (final path in groupPaths) {
        expect(canOpen(path, admin), isTrue, reason: path);
      }
    });
  });
}
