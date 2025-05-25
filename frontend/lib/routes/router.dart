import 'dart:async';

import 'package:animations/animations.dart';
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
import 'package:nocsis/pages/login.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/pages/main/layout.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/pages/settings/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'classroom_page_route.dart';
part 'console/console_calendar_page_route.dart';
part 'console/console_day_duty_page_route.dart';
part 'console/console_group_page_route.dart';
part 'console/console_member_page_route.dart';
part 'console/console_shell_route.dart';
part 'console/console_slack_page_route.dart';
part 'console/console_top_page_route.dart';
part 'console/console_weather_page_route.dart';
part 'licenses_page_route.dart';
part 'login_page_route.dart';
part 'personal/personal_events_page_route.dart';
part 'personal/personal_home_page_route.dart';
part 'personal/personal_shell_route.dart';
part 'router.g.dart';
part 'settings/settings_shell_route.dart';
part 'settings/settings_top_page_route.dart';

@TypedShellRoute<AppShell>(
  routes: [
    classroomPageRoute,
    consoleShellRoute,
    licensesPageRoute,
    loginPageRoute,
    personalShellRoute,
    settingsShellRoute,
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

Future<String?> _redirectNotLoggedInUser(GoRouterState state) async {
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final isLoggedIn = user != null;

  if (isLoggedIn || state.matchedLocation == LoginPageRoute().location) {
    return null;
  }

  final continueUri = state.uri.toString() == "/" ? null : state.uri;
  return LoginPageRoute(continueUri: continueUri).location;
}

Future<String?> _redirectLoggedInUser(GoRouterState state) async {
  final user = await FirebaseAuth.instance.authStateChanges().first;
  final isLoggedIn = user != null;

  if (!isLoggedIn || state.matchedLocation != LoginPageRoute().location) {
    return null;
  }

  final continueUri = Uri.tryParse(
    state.uri.queryParameters["continue-uri"] ?? "/",
  );

  if (continueUri == null) {
    return "/";
  }

  return await _redirectFromOldPaths(continueUri) ?? continueUri.toString();
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
        ).httpsCallable("v4-groups-user_joined_groups-get").call();
    final data = UserJoinedGroups.fromJson(res.data);

    final firstUserJoinedGroup = data.groups.first;

    sharedPreferences.setString(
      'latest_group_id',
      firstUserJoinedGroup.groupId,
    );

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
    return await _redirectNotLoggedInUser(state) ??
        await _redirectLoggedInUser(state) ??
        await _redirectFromOldPaths(state.uri);
  },
);
