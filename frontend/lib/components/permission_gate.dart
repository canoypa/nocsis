import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/core/page_permissions.dart';
import 'package:nocsis/pages/not_found.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

/// 権限が無ければ child の代わりに 404 の画面を出す。表示の出し分けだけで、
/// 操作の可否はサーバが毎回判定する
@Dependencies([currentGroupId])
class PermissionGate extends ConsumerWidget {
  /// `/groups/:groupId` より後ろのパス。[pagePermissions] のキー
  final String route;
  final Widget child;

  const PermissionGate({super.key, required this.route, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final uid = ref.watch(currentUidProvider);
    if (uid == null) {
      return const _Loading();
    }

    // 値はこの uid のものだけなので、取り直し中や取り直しの失敗時も前の値で判定してよい。
    // 一度も取れていない間は、失敗していても 404 にせず取り直しを待つ（教室の画面を固めない）
    final permissions = ref.watch(groupPermissionsProvider(uid, groupId));
    if (!permissions.hasValue) {
      return const _Loading();
    }

    // 権限が無いことと、グループの存在を区別しない
    if (!canOpenPage(route, permissions.requireValue)) {
      return const ErrorPage();
    }

    return child;
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
