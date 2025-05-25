import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/personal/user_avatar.dart';
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
        ListTile(
          title: const Text("設定"),
          onTap: () {
            final groupId =
                GoRouter.of(context).state.pathParameters['groupId']!;
            SettingsTopPageRoute(groupId).go(context);
          },
        ),
        ListTile(
          title: const Text("ログアウト"),
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
        ),
        if (true /* isAdmin */ ) ...[
          const Divider(),
          ListTile(
            title: const Text("管理コンソール"),
            onTap: () {
              final groupId =
                  GoRouter.of(context).state.pathParameters['groupId']!;
              ConsoleTopPageRoute(groupId).go(context);
            },
          ),
          ListTile(
            title: const Text("Classroom を起動"),
            onTap: () {
              final groupId =
                  GoRouter.of(context).state.pathParameters['groupId']!;
              ClassroomPageRoute(groupId).go(context);
            },
          ),
        ],
        const Divider(),
        ListTile(
          title: const Text("ライセンス"),
          onTap: () {
            const LicensesPageRoute().go(context);
          },
        ),
      ],
    );
  }
}
