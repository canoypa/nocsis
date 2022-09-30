import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// PagePath.x.path を引数に指定できないので PagePath をそのまま入れてる
enum Navigation {
  home(
    label: "ホーム",
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    pagePath: "/",
  ),
  events(
    label: "イベント",
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    pagePath: "/events",
  );

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String pagePath;

  const Navigation({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.pagePath,
  });

  factory Navigation.fromPagePath(String location) {
    return values.firstWhere(
      (element) => element.pagePath == location,
      orElse: () => Navigation.home,
    );
  }
}

class MainPage extends StatelessWidget {
  final Widget child;
  final String location;

  const MainPage({
    super.key,
    required this.child,
    required this.location,
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
        GoRouter.of(context).go(Navigation.values[value].pagePath);
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
        GoRouter.of(context).go(Navigation.values[value].pagePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigation.fromPagePath(location);

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
