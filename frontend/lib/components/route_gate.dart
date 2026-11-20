import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/core/route_access.dart';
import 'package:nocsis/pages/not_found.dart';
import 'package:nocsis/providers/me.dart';

/// [routeAccess] の宣言を満たさなければ child の代わりに 404 の画面を出す。
/// ログインの要否は router の redirect が見る。表示の出し分けだけで、
/// 操作の可否はサーバが毎回判定する
class RouteGate extends ConsumerWidget {
  /// go_router のルートのパス（`:groupId` を含む形）
  final String path;
  final String? groupId;
  final Widget child;

  const RouteGate({
    super.key,
    required this.path,
    required this.groupId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!needsGroupPermissions(path)) {
      return canOpen(path, const {}) ? child : const ErrorPage();
    }

    final groupId = this.groupId;
    final uid = ref.watch(currentUidProvider);
    if (groupId == null || uid == null) {
      return const _Loading();
    }

    // 値はこの uid のものだけなので、取り直し中や取り直しの失敗時も前の値で判定してよい。
    // 一度も取れていない間は、失敗していても 404 にせず取り直しを待つ（教室の画面を固めない）
    final permissions = ref.watch(groupPermissionsProvider(uid, groupId));
    if (!permissions.hasValue) {
      return const _Loading();
    }

    // 権限が無いことと、グループの存在を区別しない
    return canOpen(path, permissions.requireValue) ? child : const ErrorPage();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
