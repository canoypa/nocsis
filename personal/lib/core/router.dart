import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_personal/pages/main/events/page.dart';
import 'package:nocsis_personal/pages/main/home/page.dart';
import 'package:nocsis_personal/pages/main/layout.dart';
import 'package:nocsis_personal/pages/signin/page.dart';

class GoRouterRefresher extends ChangeNotifier {
  late final StreamSubscription<dynamic> _auth;

  GoRouterRefresher() {
    notifyListeners();

    _auth = FirebaseAuth.instance
        .authStateChanges()
        .asBroadcastStream()
        .listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _auth.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  redirect: (context, state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.matchedLocation != "/signin") {
      return "/signin?continue=${state.path}";
    }

    if (isSignIn && state.matchedLocation == "/signin") {
      final continueUri = state.uri.queryParameters["continue"];
      final validUriPattern = RegExp(r"^/.+$");

      if (continueUri is String && validUriPattern.hasMatch(continueUri)) {
        return continueUri;
      }

      return "/";
    }

    return null;
  },
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) {
        return MaterialPage(
          key: state.pageKey,
          child: MainPage(
            location: state.matchedLocation,
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: "/",
          pageBuilder: (context, state) {
            final isMobile = MediaQuery.of(context).size.width < 1200;

            return CustomTransitionPage(
              key: state.pageKey,
              child: const MainView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                if (isMobile) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                }

                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: "/events",
          pageBuilder: (context, state) {
            final isMobile = MediaQuery.of(context).size.width < 1200;

            return CustomTransitionPage(
              key: state.pageKey,
              child: const EventsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                if (isMobile) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                }

                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
            );
          },
        )
      ],
    ),
    GoRoute(
      path: "/signin",
      pageBuilder: (context, state) {
        return const MaterialPage(
          child: SignInPage(),
        );
      },
    ),
  ],
  refreshListenable: GoRouterRefresher(),
);
