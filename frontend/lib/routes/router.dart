import 'dart:async';

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
