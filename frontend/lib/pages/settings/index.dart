import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsTopRoute extends GoRouteData {
  const SettingsTopRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SettingsTopPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

class SettingsTopPage extends StatelessWidget {
  const SettingsTopPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '設定',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 48),
            Text(
              'アカウント',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メールアドレス',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(FirebaseAuth.instance.currentUser?.email ?? ''),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    // TODO
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const ChangeEmailDialog();
                        });
                  },
                  child: const Text('変更する'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChangeEmailDialog extends StatelessWidget {
  const ChangeEmailDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text('メールアドレスを変更する'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '新しいメールアドレス',
              ),
            ),
            const SizedBox(height: 16),
            const Text('入力したメールアドレス宛に届くリンクを開くと、メールアドレスが変更されます。'),
            const Text('連携している Google アカウントは変わらないので、注意してください。'),
            const Text(
                '「新しいメールアドレスでログインできるようになりました」と表示されますが、現在 Google アカウント以外でログインする方法はないため、この内容は無視してください。')
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();

            await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(
              emailController.text,
            );
          },
          child: const Text('確定'),
        ),
      ],
    );
  }
}
