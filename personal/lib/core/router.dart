import 'dart:async';

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
      builder: (context, state, child) {
        return MainPage(
          location: state.subloc,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) {
            return const MainView();
          },
        ),
        GoRoute(
          path: "/events",
          builder: (context, state) {
            return const EventsView();
          },
        )
      ],
    ),
    GoRoute(
      path: "/signin",
      builder: (context, state) {
        return const SignInPage();
      },
    ),
  ],
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
);
