import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/custom_icons.dart';

class SettingsSignInRoute extends GoRouteData {
  const SettingsSignInRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SettingsSignInPage(),
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

class SettingsSignInPage extends StatelessWidget {
  const SettingsSignInPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final googleEmail = FirebaseAuth.instance.currentUser!.providerData
        .firstWhere((e) => e.providerId == GoogleAuthProvider.PROVIDER_ID)
        .email;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'サインイン',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(CustomIcons.google),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Google でサインイン',
                              style: Theme.of(context).textTheme.titleMedium),
                          if (googleEmail != null)
                            Text(
                              googleEmail,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  // TODO: unlink と　link の順番的にログイン不能になる危険があるので、メアドログインを有効にしてなければボタンを無効化する
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.currentUser!
                          .unlink(GoogleAuthProvider.PROVIDER_ID);
                      await FirebaseAuth.instance.currentUser!
                          .linkWithPopup(GoogleAuthProvider());
                    },
                    child: const Text("別アカウントと連携する"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
