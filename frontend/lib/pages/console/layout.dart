import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/custom_icons.dart';
import 'package:nocsis/pages/console/calendar.dart';
import 'package:nocsis/pages/console/dayduty.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/console/members.dart';
import 'package:nocsis/pages/console/slack.dart';
import 'package:nocsis/pages/console/group.dart';
import 'package:nocsis/pages/console/weather.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/templates/drawer_layout.dart';

class ConsoleShellRoute extends ShellRouteData {
  const ConsoleShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ConsoleLayout(
      child: navigator,
    );
  }
}

class ConsoleLayout extends StatelessWidget {
  final Widget child;

  const ConsoleLayout({
    super.key,
    required this.child,
  });

  static final Map<String, int> _routeToIndex = {
    const ConsoleTopRoute().location: 0,
    const ConsoleGroupRoute().location: 1,
    const ConsoleMemberRoute().location: 2,
    const ConsoleCalendarRoute().location: 3,
    const ConsoleDayDutyRoute().location: 4,
    const ConsoleWeatherRoute().location: 5,
    const ConsoleSlackRoute().location: 6,
  };

  int _getNavigationIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return _routeToIndex[location] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DrawerLayout(
      title: const Text('管理コンソール'),
      navigationIndex: _getNavigationIndex(context),
      onDestinationSelected: (value) {
        final route = _routeToIndex.entries
            .firstWhere((entry) => entry.value == value)
            .key;
        GoRouter.of(context).go(route);
      },
      navigationItems: const [
        NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('ホーム'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.workspaces_outlined),
          selectedIcon: Icon(Icons.workspaces),
          label: Text('グループ'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: Text('メンバー'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('カレンダー'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person_pin_outlined),
          selectedIcon: Icon(Icons.person_pin_rounded),
          label: Text('日直'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny),
          label: Text('気象/室温データ連携'),
        ),
        NavigationDrawerDestination(
          icon: Icon(CustomIcons.slack_outlined),
          selectedIcon: Icon(CustomIcons.slack),
          label: Text('Slack 連携'),
        ),
      ],
      child: child,
    );
  }
}
