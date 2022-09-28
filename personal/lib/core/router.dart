import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_personal/pages/main/events/page.dart';
import 'package:nocsis_personal/pages/main/home/page.dart';
import 'package:nocsis_personal/pages/main/layout.dart';
import 'package:nocsis_personal/pages/signin/page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();

    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  redirect: (context, state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.subloc != "/signin") {
      return "/signin?continue=${state.path}";
    }

    if (isSignIn && state.subloc == "/signin") {
      final continueUri = state.queryParams["continue"];
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
            location: state.subloc,
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: "/",
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const MainView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: "/events",
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const EventsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
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
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
);
