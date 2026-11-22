import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/components/personal/user_avatar.dart';
import 'package:nocsis/core/route_access.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:nocsis/routes/router.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final granted = watchGrantedPermissions(ref, groupId);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          icon: const UserAvatar(),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () => SettingsTopPageRoute(groupId).go(context),
          child: const Text("設定"),
        ),
        MenuItemButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: const Text("ログアウト"),
        ),
        if (canOpen(ConsoleTopPageRoute.path, granted) ||
            canOpen(ClassroomPageRoute.path, granted))
          const Divider(),
        if (canOpen(ConsoleTopPageRoute.path, granted))
          MenuItemButton(
            onPressed: () => ConsoleTopPageRoute(groupId).go(context),
            child: const Text("管理コンソール"),
          ),
        if (canOpen(ClassroomPageRoute.path, granted))
          MenuItemButton(
            onPressed: () => ClassroomPageRoute(groupId).go(context),
            child: const Text("教室ディスプレイを表示"),
          ),
        const Divider(),
        MenuItemButton(
          onPressed: () {
            const LicensesPageRoute().go(context);
          },
          child: const Text("ライセンス"),
        ),
      ],
    );
  }
}
