import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/personal/user_avatar.dart';
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
  final Widget child;

  const DrawerLayout({
    super.key,
    required this.child,
  });

  int getSelectedIndex(BuildContext context) {
    if (GoRouterState.of(context).matchedLocation == '/console') {
      return 0;
    } else if (GoRouterState.of(context).matchedLocation == '/console/group') {
      return 1;
    } else if (GoRouterState.of(context).matchedLocation == '/console/member') {
      return 2;
    } else if (GoRouterState.of(context).matchedLocation ==
        '/console/calendar') {
      return 3;
    } else if (GoRouterState.of(context).matchedLocation ==
        '/console/day_duty') {
      return 4;
    } else if (GoRouterState.of(context).matchedLocation ==
        '/console/weather') {
      return 5;
    } else if (GoRouterState.of(context).matchedLocation == '/console/slack') {
      return 6;
    }
    return 0;
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
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                icon: const UserAvatar(),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                child: const Text("設定"),
                onPressed: () {
                  // TODO
                },
              ),
              MenuItemButton(
                child: const Text("ログアウト"),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
              if (true /* isAdmin */) ...[
                const Divider(),
                MenuItemButton(
                  child: const Text("管理コンソール"),
                  onPressed: () {
                    // TODO
                  },
                ),
                MenuItemButton(
                  child: const Text("Classroom を起動"),
                  onPressed: () {
                    const HomeRoute().go(context);
                  },
                ),
              ],
              const Divider(),
              MenuItemButton(
                child: const Text("ライセンス"),
                onPressed: () {
                  const LicensesRoute().go(context);
                },
              )
            ],
          ),
        ],
        title: const Text('管理コンソール'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationDrawer(
            onDestinationSelected: (value) {
              switch (value) {
                case 0:
                  const ConsoleTopRoute().go(context);
                  break;
                case 1:
                  const ConsoleGroupRoute().go(context);
                  break;
                case 2:
                  const ConsoleMemberRoute().go(context);
                  break;
                case 3:
                  const ConsoleCalendarRoute().go(context);
                  break;
                case 4:
                  const ConsoleDayDutyRoute().go(context);
                  break;
                case 5:
                  const ConsoleWeatherRoute().go(context);
                  break;
                case 6:
                  const ConsoleSlackRoute().go(context);
                  break;
              }
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
