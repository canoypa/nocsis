import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_classroom/pages/main/events/page.dart';
import 'package:nocsis_classroom/pages/main/home/page.dart';
import 'package:nocsis_classroom/pages/main/layout.dart';
import 'package:nocsis_classroom/themes/display.dart';
import 'package:nocsis_classroom/pages/sign_in.dart';
import 'package:nocsis_classroom/screens/home.dart';

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
  routes: [
    GoRoute(
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: ScreenUtilInit(
            designSize: const Size(960, 540),
            builder: (context, child) {
              final theme = createDisplayTheme(context);

              return Theme(
                data: theme,
                child: const Scaffold(
                  body: HomeScreen(),
                ),
              );
            },
          ),
        );
      },
    ),
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
          path: "/personal",
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
          path: "/personal/events",
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
        return MaterialPage(
          key: state.pageKey,
          child: const SignInPage(),
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.matchedLocation != "/signin") {
      final continueUri = state.uri.path;
      if (continueUri == "/") {
        return "/signin";
      }

      return "/signin?continue=${continueUri}";
    }

    if (isSignIn && state.matchedLocation == "/signin") {
      final continueUri =
          Uri.tryParse(state.uri.queryParameters["continue"] ?? "");

      if (continueUri != null) {
        return continueUri.path;
      }

      return "/";
    }

    return null;
  },
  refreshListenable: GoRouterRefresher(),
);
