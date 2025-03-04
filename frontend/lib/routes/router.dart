import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/models/user_joined_groups.dart';
import 'package:nocsis/pages/classroom.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

part 'router.g.dart';

@TypedShellRoute<AppShell>(
  routes: [
    TypedGoRoute<SignInRoute>(path: '/sign_in'),

    // 新Path
    TypedShellRoute<PersonalShell>(
      routes: [
        TypedGoRoute<PersonalHomeRoute>(path: '/groups/:groupId'),
        TypedGoRoute<PersonalEventsRoute>(path: '/groups/:groupId/events'),
      ],
    ),
    TypedGoRoute<ClassroomRoute>(path: '/groups/:groupId/classroom'),
    TypedShellRoute<ConsoleShellRoute>(
      routes: [
        TypedGoRoute<ConsoleTopRoute>(path: '/groups/:groupId/console'),
        TypedGoRoute<ConsoleGroupRoute>(path: '/groups/:groupId/console/group'),
        TypedGoRoute<ConsoleMemberRoute>(
          path: '/groups/:groupId/console/member',
        ),
        TypedGoRoute<ConsoleCalendarRoute>(
          path: '/groups/:groupId/console/calendar',
        ),
        TypedGoRoute<ConsoleDayDutyRoute>(
          path: '/groups/:groupId/console/day_duty',
        ),
        TypedGoRoute<ConsoleWeatherRoute>(
          path: '/groups/:groupId/console/weather',
        ),
        TypedGoRoute<ConsoleSlackRoute>(path: '/groups/:groupId/console/slack'),
      ],
    ),
    TypedShellRoute<SettingsShellRoute>(
      routes: [
        TypedGoRoute<SettingsTopRoute>(path: '/groups/:groupId/settings'),
      ],
    ),

    TypedGoRoute<LicensesRoute>(path: '/licenses'),
  ],
)
class AppShell extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }
}

class GoRouterRefresher extends ChangeNotifier {
  late final StreamSubscription<dynamic> _auth;

  GoRouterRefresher() {
    notifyListeners();

    _auth = FirebaseAuth.instance.authStateChanges().asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
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
  redirect: (context, state) async {
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
      final continueUri = Uri.tryParse(
        state.uri.queryParameters["continue"] ?? "/",
      );

      if (continueUri != null) {
        return continueUri.path;
      }

      return "/";
    }

    final oldPaths = [
      '/',
      '/events',
      '/classroom',
      '/console',
      '/console/group',
      '/console/member',
      '/console/calendar',
      '/console/day_duty',
      '/console/weather',
      '/console/slack',
      '/settings',
    ];
    if (oldPaths.contains(state.uri.path)) {
      final sharedPreferences = await SharedPreferences.getInstance();
      final groupId = sharedPreferences.getString('latest_group_id');

      if (groupId != null) {
        return "/groups/$groupId";
      }

      final res =
          await FirebaseFunctions.instanceFor(
            region: "asia-northeast1",
          ).httpsCallable("v4-groups-get").call();

      final data = UserJoinedGroups.fromJson(res.data);

      final firstUserJoinedGroup = data.groups.first;

      return "/groups/${firstUserJoinedGroup.groupId}";
    }

    return null;
  },
);
