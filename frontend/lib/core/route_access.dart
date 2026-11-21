import 'package:nocsis/generated/api_client/api.enums.swagger.dart';

/// ルートが誰に開けるか。宣言はパスの階層で受け継ぐ。子は親の宣言に条件を足す
/// ことしかできず、親より緩めることはできない
sealed class RouteAccess {
  const RouteAccess();
}

/// ログインしていなくても開ける
class PublicAccess extends RouteAccess {
  const PublicAccess();
}

/// ログインしていれば開ける
class SignedInAccess extends RouteAccess {
  const SignedInAccess();
}

/// URL のグループに対して、このうち1つでも持っていれば開ける。画面が行う操作を並べる
class GroupAccess extends RouteAccess {
  final Set<Permission> anyOf;

  const GroupAccess(this.anyOf);
}

const _updateGroup = {Permission.groupUpdate};
const _manageMembers = {
  Permission.memberCreate,
  Permission.memberUpdate,
  Permission.memberDelete,
};

/// キーは go_router のルートのパス（`:groupId` のようなパラメータを含む形）
const routeAccess = <String, RouteAccess>{
  '/login': PublicAccess(),
  '/': SignedInAccess(),
  '/licenses': PublicAccess(),
  '/groups/:groupId': GroupAccess({Permission.groupRead}),
  '/groups/:groupId/console': GroupAccess({..._updateGroup, ..._manageMembers}),
  '/groups/:groupId/console/group': GroupAccess(_updateGroup),
  '/groups/:groupId/console/member': GroupAccess(_manageMembers),
  '/groups/:groupId/console/calendar': GroupAccess(_updateGroup),
  '/groups/:groupId/console/day_duty': GroupAccess(_updateGroup),
  '/groups/:groupId/console/weather': GroupAccess(_updateGroup),
  '/groups/:groupId/console/slack': GroupAccess(_updateGroup),
  '/groups/:groupId/console/displays': GroupAccess({
    Permission.accessRead,
    Permission.accessCreate,
    Permission.accessDelete,
  }),
  // 日直（メンバーの一覧）を出すのは教室の画面だけ
  '/groups/:groupId/classroom': GroupAccess({Permission.memberRead}),
};

/// パスとその祖先に付いた宣言。`/groups/:groupId/console` なら
/// `/groups`、`/groups/:groupId`、`/groups/:groupId/console` の順に見る
List<RouteAccess> declarationsFor(String path) {
  if (path == '/') {
    return [?routeAccess['/']];
  }

  final segments = path.split('/').where((s) => s.isNotEmpty).toList();

  return [
    for (var i = 1; i <= segments.length; i++)
      ?routeAccess['/${segments.take(i).join('/')}'],
  ];
}

/// ログインしていなくても開けるか。宣言の無いパスは開けない側に倒す
bool isPublic(String path) {
  final declarations = declarationsFor(path);

  return declarations.isNotEmpty &&
      declarations.every((d) => d is PublicAccess);
}

/// URL のグループの権限を見る必要があるか
bool needsGroupPermissions(String path) =>
    declarationsFor(path).any((d) => d is GroupAccess);

/// ログイン済みの相手が開けるか。宣言の無いパスは開けない
bool canOpen(String path, Set<Permission> granted) {
  final declarations = declarationsFor(path);

  return declarations.isNotEmpty &&
      declarations.every(
        (declaration) => switch (declaration) {
          PublicAccess() || SignedInAccess() => true,
          GroupAccess(:final anyOf) => anyOf.any(granted.contains),
        },
      );
}
