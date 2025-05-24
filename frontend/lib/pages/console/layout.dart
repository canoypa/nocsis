import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/custom_icons.dart';
import 'package:nocsis/templates/drawer_layout.dart';

class ConsoleLayout extends StatelessWidget {
  final Widget child;

  const ConsoleLayout({super.key, required this.child});

  static final Map<String, int> _routeToIndex = {
    '/console': 0,
    '/console/group': 1,
    '/console/member': 2,
    '/console/calendar': 3,
    '/console/day_duty': 4,
    '/console/weather': 5,
    '/console/slack': 6,
  };

  int _getNavigationIndex(BuildContext context) {
    final location = GoRouterState.of(context).fullPath!;
    final routeKey = _routeToIndex.keys.firstWhere(
      (key) => location.replaceFirst('/groups/:groupId', '') == key,
      orElse: () => '/console',
    );
    return _routeToIndex[routeKey]!;
  }

  @override
  Widget build(BuildContext context) {
    return DrawerLayout(
      title: const Text('管理コンソール'),
      navigationIndex: _getNavigationIndex(context),
      onDestinationSelected: (value) {
        final groupId = GoRouter.of(context).state.pathParameters['groupId']!;
        final route =
            _routeToIndex.entries
                .firstWhere((entry) => entry.value == value)
                .key;
        GoRouter.of(context).go("/groups/$groupId$route");
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
          label: Text('気象データ連携'),
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
