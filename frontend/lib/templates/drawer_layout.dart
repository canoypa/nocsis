import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/custom_icons_icons.dart';
import 'package:nocsis/pages/console/calendar.dart';
import 'package:nocsis/pages/console/dayduty.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/console/members.dart';
import 'package:nocsis/pages/console/slack.dart';
import 'package:nocsis/pages/console/team.dart';
import 'package:nocsis/pages/console/weather.dart';
import 'package:nocsis/routes/router.dart';

class DrawerLayout extends StatelessWidget {
  final Widget title;
  final Widget child;

  const DrawerLayout({
    super.key,
    required this.title,
    required this.child,
  });

  static Map<String, int> routeToIndex = {
    const ConsoleTopRoute().location: 0,
    const ConsoleGroupRoute().location: 1,
    const ConsoleMemberRoute().location: 2,
    const ConsoleCalendarRoute().location: 3,
    const ConsoleDayDutyRoute().location: 4,
    const ConsoleWeatherRoute().location: 5,
    const ConsoleSlackRoute().location: 6,
  };

  int getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return routeToIndex[location] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              const HomeRoute().go(context);
            }
          },
        ),
        actions: const [AccountMenu()],
        title: title,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationDrawer(
            onDestinationSelected: (value) {
              final route = routeToIndex.entries
                  .firstWhere((entry) => entry.value == value)
                  .key;
              GoRouter.of(context).go(route);
            },
            selectedIndex: getSelectedIndex(context),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            children: const [
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
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
