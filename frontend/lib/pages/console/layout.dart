import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nocsis/core/route_access.dart';
import 'package:nocsis/custom_icons.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/templates/drawer_layout.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class ConsoleLayout extends ConsumerWidget {
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
    '/console/displays': 7,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final granted = watchGrantedPermissions(ref, groupId);

    return DrawerLayout(
      title: const Text('管理コンソール'),
      navigationIndex: _getNavigationIndex(context),
      onDestinationSelected: (value) {
        final route = _routeToIndex.entries
            .firstWhere((entry) => entry.value == value)
            .key;
        GoRouter.of(context).go("/groups/$groupId$route");
      },
      navigationItems: [
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
        // 最後に置く。出し分けても、ほかの項目の番号がずれない
        if (canOpen(ConsoleDisplaysPageRoute.path, granted))
          const NavigationDrawerDestination(
            icon: Icon(Symbols.tv),
            selectedIcon: Icon(Symbols.tv, fill: 1),
            label: Text('教室ディスプレイ'),
          ),
      ],
      child: child,
    );
  }
}
