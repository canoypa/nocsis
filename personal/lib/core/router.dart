import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';
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
  routes: [
    ShellRoute(
      path: "/",
      defaultRoute: "home",
      redirect: (state) async {
        final user = await FirebaseAuth.instance.authStateChanges().first;
        final isSignIn = user != null;

        if (!isSignIn) {
          return "/signin?continue=${state.path}";
        }

        return null;
      },
      builder: (context, child) {
        return MainPage(child: child);
      },
      routes: [
        StackedRoute(
          path: "home",
          builder: (context) {
            return const MainView();
          },
        ),
        StackedRoute(
          path: "events",
          builder: (context) {
            return const EventsView();
          },
        )
      ],
    ),
    StackedRoute(
      path: "/signin",
      redirect: (state) async {
        final user = await FirebaseAuth.instance.authStateChanges().first;
        final isSignIn = user != null;

        final continueUri = state.parameters.query["continue"];
        final validUriPattern = RegExp(r"^/.+$");

        if (isSignIn) {
          if (continueUri is String && validUriPattern.hasMatch(continueUri)) {
            return continueUri;
          }

          return "/";
        }

        return null;
      },
      builder: (context) {
        return const SignInPage();
      },
    )
  ],
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
);
