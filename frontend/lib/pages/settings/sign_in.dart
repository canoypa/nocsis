import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            TextButton(
              onPressed: () async {
                final googleUser = await GoogleSignIn(
                  clientId:
                      '219141289630-1duqb26tbk7dte61804hjqg64qmhfsc2.apps.googleusercontent.com',
                ).signInSilently();
                if (googleUser == null) return;
                print(googleUser);

                final authentication = await googleUser.authentication;
                print(authentication);

                final newCredential = GoogleAuthProvider.credential(
                  accessToken: authentication.accessToken,
                  idToken: authentication.idToken,
                );
                print(newCredential);

                await FirebaseAuth.instance.currentUser!
                    .unlink(GoogleAuthProvider.PROVIDER_ID);
                print('unlink');

                await FirebaseAuth.instance.currentUser!
                    .linkWithCredential(newCredential);
                print('link');
              },
              child: const Text("別アカウントと連携する"),
            ),
          ],
        ),
      ),
    );
  }
}
