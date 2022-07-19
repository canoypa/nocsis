import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_personal/core/router.dart';
import 'package:nocsis_personal/widget/events_view.dart';
import 'package:nocsis_personal/widget/main_view.dart';

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

  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      label: label,
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
    );
  }
}

class MainPage extends StatelessWidget {
  final String loc;

  const MainPage({
    super.key,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Navigation.fromPagePath(loc);

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: IndexedStack(
            index: nav.index,
            children: const [
              MainView(),
              EventsView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        destinations:
            Navigation.values.map((e) => e.toNavigationDestination()).toList(),
        onDestinationSelected: (value) {
          GoRouter.of(context).go(Navigation.values[value].pagePath.path);
        },
      ),
    );
  }
}
