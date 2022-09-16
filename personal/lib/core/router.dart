import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';
import 'package:nocsis_personal/pages/main.dart';
import 'package:nocsis_personal/pages/sign_in.dart';
import 'package:nocsis_personal/widget/events_view.dart';
import 'package:nocsis_personal/widget/main_view.dart';

enum PagePath {
  home("home"),
  events("events"),
  signin("/signin");

  final String path;

  const PagePath(this.path);
}

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

        final loc = state.path;

        if (!isSignIn && loc != PagePath.signin.path) {
          return PagePath.signin.path;
        }

        return null;
      },
      builder: (context, child) {
        return MainPage(child: child);
      },
      routes: [
        StackedRoute(
          path: PagePath.home.path,
          builder: (context) {
            return const MainView();
          },
        ),
        StackedRoute(
          path: PagePath.events.path,
          builder: (context) {
            return const EventsView();
          },
        )
      ],
    ),
    StackedRoute(
      path: PagePath.signin.path,
      redirect: (state) async {
        final user = await FirebaseAuth.instance.authStateChanges().first;
        final isSignIn = user != null;

        final loc = state.path;

        if (isSignIn && loc == PagePath.signin.path) {
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
