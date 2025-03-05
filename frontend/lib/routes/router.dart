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

Future<String?> _redirectNotSignedInUser(Uri uri) async {
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final isSignIn = user != null;

  if (!isSignIn && uri.path != "/sign_in") {
    final continueUri = uri.path;
    if (continueUri == "/") {
      return "/sign_in";
    }

    return "/sign_in?continue=$continueUri";
  }

  return null;
}

Future<String?> _redirectSignedInUser(Uri uri) async {
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final isSignIn = user != null;

  if (isSignIn && uri.path == "/sign_in") {
    final continueUri = Uri.tryParse(uri.queryParameters["continue"] ?? "/");

    if (continueUri != null) {
      return await _redirectFromOldPaths(continueUri) ?? continueUri.path;
    }

    return "/";
  }

  return null;
}

Future<String?> _redirectFromOldPaths(Uri uri) async {
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

  if (oldPaths.contains(uri.path)) {
    final sharedPreferences = await SharedPreferences.getInstance();
    final groupId = sharedPreferences.getString('latest_group_id');

    if (groupId != null) {
      return uri.path == '/'
          ? "/groups/$groupId"
          : "/groups/$groupId${uri.path}";
    }

    final res =
        await FirebaseFunctions.instanceFor(
          region: "asia-northeast1",
        ).httpsCallable("v4-groups-get").call();

    final data = UserJoinedGroups.fromJson(res.data);

    final firstUserJoinedGroup = data.groups.first;

    return uri.path == '/'
        ? "/groups/${firstUserJoinedGroup.groupId}"
        : "/groups/${firstUserJoinedGroup.groupId}${uri.path}";
  }

  return null;
}

final router = GoRouter(
  routes: $appRoutes,
  refreshListenable: GoRouterRefresher(),
  redirect: (context, state) async {
    return await _redirectNotSignedInUser(state.uri) ??
        await _redirectSignedInUser(state.uri) ??
        await _redirectFromOldPaths(state.uri);
  },
);
