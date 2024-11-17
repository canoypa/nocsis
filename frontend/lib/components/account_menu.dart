import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nocsis/components/personal/user_avatar.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/routes/router.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: const Text("設定"),
          onPressed: () {
            const SettingsTopRoute().go(context);
          },
        ),
        MenuItemButton(
          child: const Text("ログアウト"),
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
        ),
        if (true /* isAdmin */) ...[
          const Divider(),
          MenuItemButton(
            child: const Text("管理コンソール"),
            onPressed: () {
              const ConsoleTopRoute().go(context);
            },
          ),
          MenuItemButton(
            child: const Text("Classroom を起動"),
            onPressed: () {
              const HomeRoute().go(context);
            },
          ),
        ],
        const Divider(),
        MenuItemButton(
          child: const Text("ライセンス"),
          onPressed: () {
            const LicensesRoute().go(context);
          },
        )
      ],
    );
  }
}
