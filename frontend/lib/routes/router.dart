import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/pages/console/calendar.dart';
import 'package:nocsis/pages/console/dayduty.dart';
import 'package:nocsis/pages/console/group.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/console/layout.dart';
import 'package:nocsis/pages/console/members.dart';
import 'package:nocsis/pages/console/slack.dart';
import 'package:nocsis/pages/console/weather.dart';
import 'package:nocsis/pages/licenses.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/pages/main/layout.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/pages/settings/layout.dart';
import 'package:nocsis/pages/settings/sign_in.dart';
import 'package:nocsis/pages/sign_in.dart';
import 'package:nocsis/screens/home.dart';

part 'router.g.dart';

@TypedShellRoute<AppShell>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<SignInRoute>(path: '/sign_in'),
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
    TypedShellRoute<SettingsShellRoute>(routes: [
      TypedGoRoute<SettingsTopRoute>(path: '/settings'),
      TypedGoRoute<SettingsSignInRoute>(path: '/settings/sign_in'),
    ]),
    TypedGoRoute<LicensesRoute>(path: '/licenses'),
  ],
)
class AppShell extends ShellRouteData {
  @override
  Page<void> pageBuilder(
      BuildContext context, GoRouterState state, Widget navigator) {
    return CustomTransitionPage(
      child: navigator,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.uri.path != "/sign_in") {
      final continueUri = state.uri.path;
      if (continueUri == "/") {
        return "/sign_in";
      }

      return "/sign_in?continue=$continueUri";
    }

    if (isSignIn && state.uri.path == "/sign_in") {
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
    return CustomTransitionPage(
      key: state.pageKey,
      child: const HomeScreen(),
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

class SignInRoute extends GoRouteData {
  const SignInRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SignInPage(),
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

class PersonalShell extends ShellRouteData {
  const PersonalShell();

  @override
  Page<void> pageBuilder(
      BuildContext context, GoRouterState state, Widget navigator) {
    return CustomTransitionPage(
      child: MainPage(
        location: state.matchedLocation,
        child: navigator,
      ),
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
    return CustomTransitionPage(
      key: state.pageKey,
      child: const LicensesPage(),
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
