import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/pages/console/calendar.dart';
import 'package:nocsis/pages/console/dayduty.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/console/layout.dart';
import 'package:nocsis/pages/console/members.dart';
import 'package:nocsis/pages/console/slack.dart';
import 'package:nocsis/pages/console/group.dart';
import 'package:nocsis/pages/console/weather.dart';
import 'package:nocsis/pages/licenses.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/pages/main/layout.dart';
import 'package:nocsis/themes/display.dart';
import 'package:nocsis/pages/sign_in.dart';
import 'package:nocsis/screens/home.dart';

part 'router.g.dart';

@TypedShellRoute<AppShell>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<SignInRoute>(path: '/signin'),
    TypedShellRoute<PersonalShell>(
      routes: [
        TypedGoRoute<PersonalHomeRoute>(path: '/personal'),
        TypedGoRoute<PersonalEventsRoute>(path: '/personal/events'),
      ],
    ),
    TypedShellRoute<ConsoleShellRoute>(routes: [
      TypedGoRoute<ConsoleTopRoute>(path: '/console'),
      TypedGoRoute<ConsoleGroupRoute>(path: '/console/group'),
      TypedGoRoute<ConsoleMemberRoute>(path: '/console/member'),
      TypedGoRoute<ConsoleCalendarRoute>(path: '/console/calendar'),
      TypedGoRoute<ConsoleDayDutyRoute>(path: '/console/day_duty'),
      TypedGoRoute<ConsoleWeatherRoute>(path: '/console/weather'),
      TypedGoRoute<ConsoleSlackRoute>(path: '/console/slack'),
    ]),
    TypedGoRoute<LicensesRoute>(path: '/licenses'),
  ],
)
class AppShell extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.uri.path != "/signin") {
      final continueUri = state.uri.path;
      if (continueUri == "/") {
        return "/signin";
      }

      return "/signin?continue=$continueUri";
    }

    if (isSignIn && state.uri.path == "/signin") {
      final continueUri =
          Uri.tryParse(state.uri.queryParameters["continue"] ?? "/");

      if (continueUri != null) {
        return continueUri.path;
      }

      return "/";
    }

    return null;
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
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
  }
}

class SignInRoute extends GoRouteData {
  const SignInRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const SignInPage(),
    );
  }
}

class PersonalShell extends ShellRouteData {
  const PersonalShell();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainPage(
      location: state.matchedLocation,
      child: navigator,
    );
  }
}

class PersonalHomeRoute extends GoRouteData {
  const PersonalHomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return CustomTransitionPage(
      key: state.pageKey,
      child: const MainView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }
}

class PersonalEventsRoute extends GoRouteData {
  const PersonalEventsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return CustomTransitionPage(
      key: state.pageKey,
      child: const EventsView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }
}

class LicensesRoute extends GoRouteData {
  const LicensesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const LicensesPage(),
    );
  }
}

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
  routes: $appRoutes,
  refreshListenable: GoRouterRefresher(),
);
