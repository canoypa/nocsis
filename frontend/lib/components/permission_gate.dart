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
    final permissions = ref.watch(groupPermissionsProvider(groupId));

    // 再取得中や失敗時の value は前の値（前のアカウントのこともある）なので使わない
    if (permissions.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 権限が無いことと、グループの存在を区別しない
    if (permissions.hasError || !canOpenPage(route, permissions.requireValue)) {
      return const ErrorPage();
    }

    return child;
  }
}
