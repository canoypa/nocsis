import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            const Text('Google'),
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
    );
  }
}
