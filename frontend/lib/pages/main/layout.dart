import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/routes/router.dart';

class PersonalShell extends ShellRouteData {
  const PersonalShell();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: MainPage(location: state.matchedLocation, child: navigator),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

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

  const MainPage({super.key, required this.child, required this.location});

  Widget _buildNavRail(BuildContext context, Navigation navigation) {
    return NavigationRail(
      // top padding, but it doesn't look like it
      leading: const SizedBox(height: 8),
      selectedIndex: navigation.index,
      destinations:
          Navigation.values
              .map(
                (e) => NavigationRailDestination(
                  label: Text(e.label),
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selectedIcon),
                ),
              )
              .toList(),
      onDestinationSelected: (value) {
        final nav = Navigation.values[value];

        if (nav == Navigation.home) {
          const PersonalHomeRoute().go(context);
        } else if (nav == Navigation.events) {
          const PersonalEventsRoute().go(context);
        }
      },
      labelType: NavigationRailLabelType.all,
    );
  }

  Widget _buildNavBar(BuildContext context, Navigation navigation) {
    return NavigationBar(
      selectedIndex: navigation.index,
      destinations:
          Navigation.values
              .map(
                (e) => NavigationDestination(
                  label: e.label,
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selectedIcon),
                ),
              )
              .toList(),
      onDestinationSelected: (value) {
        final nav = Navigation.values[value];

        if (nav == Navigation.home) {
          const PersonalHomeRoute().go(context);
        } else if (nav == Navigation.events) {
          const PersonalEventsRoute().go(context);
        }
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
          appBar: AppBar(actions: const [AccountMenu()]),
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
