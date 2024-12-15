import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/sign_in_form.dart';

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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: SignInForm(
                            title: "メールアドレスを変更する",
                            description: '始めに、現在のアカウントで再認証が必要です。',
                            onGoogleSignIn: () async {
                              await FirebaseAuth.instance.currentUser
                                  ?.reauthenticateWithPopup(
                                      GoogleAuthProvider());

                              Navigator.of(context).pop();

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const ChangeEmailDialog();
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
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

    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'メールアドレスを変更する',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
                '1. 新しいメールアドレスを入力して、「確認する」を押してください。\n2. 入力したメールアドレス宛に確認のメールが届きます。メールに含まれるリンクを開いて、メールアドレスの変更を完了してください。'),
            const SizedBox(height: 8),
            const Text(
                '※ 連携している Google アカウントは変更されません。\n※ 「新しいメールアドレスでログインできるようになりました」と表示されますが、現在 Google アカウント以外でログインする方法はないため、この内容は無視してください。'),
            const SizedBox(height: 48),
            TextField(
              autofocus: true,
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '新しいメールアドレス',
                hintText: 'yourname@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.verifyBeforeUpdateEmail(
                    emailController.text,
                  );

                  Navigator.of(context).pop();
                },
                child: const Text('確認する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
