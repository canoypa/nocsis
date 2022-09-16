import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';
import 'package:nocsis_personal/core/router.dart';

// PagePath.x.path を引数に指定できないので PagePath をそのまま入れてる
enum Navigation {
  home(
    label: "ホーム",
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    pagePath: PagePath.home,
  ),
  events(
    label: "イベント",
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    pagePath: PagePath.events,
  );

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final PagePath pagePath;

  const Navigation({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pagePath,
  });

  factory Navigation.fromPagePath(String location) {
    return values.firstWhere(
      (element) => element.pagePath.path == location,
      orElse: () => Navigation.home,
    );
  }
}

class MainPage extends StatelessWidget {
  final Widget child;

  const MainPage({
    super.key,
    required this.child,
  });

  Widget _buildNavRail(BuildContext context, Navigation navigation) {
    return NavigationRail(
      // top padding, but it doesn't look like it
      leading: const SizedBox(height: 8),
      selectedIndex: navigation.index,
      destinations: Navigation.values
          .map(
            (e) => NavigationRailDestination(
              label: Text(e.label),
              icon: Icon(e.icon),
              selectedIcon: Icon(e.selectedIcon),
            ),
          )
          .toList(),
      onDestinationSelected: (value) {
        RouteState.of(context).goTo(Navigation.values[value].pagePath.path);
      },
      labelType: NavigationRailLabelType.all,
    );
  }

  Widget _buildNavBar(BuildContext context, Navigation navigation) {
    return NavigationBar(
      selectedIndex: navigation.index,
      destinations: Navigation.values
          .map(
            (e) => NavigationDestination(
              label: e.label,
              icon: Icon(e.icon),
              selectedIcon: Icon(e.selectedIcon),
            ),
          )
          .toList(),
      onDestinationSelected: (value) {
        RouteState.of(context).goTo(Navigation.values[value].pagePath.path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = RouteState.of(context).route.path;
    final nav = Navigation.fromPagePath(loc);

    return LayoutBuilder(
      builder: ((context, constraints) {
        final bool isLargeScreen = constraints.minWidth >= 1200;

        return Scaffold(
          body: Row(
            children: [
              if (isLargeScreen) _buildNavRail(context, nav),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar:
              !isLargeScreen ? _buildNavBar(context, nav) : null,
        );
      }),
    );
  }
}
