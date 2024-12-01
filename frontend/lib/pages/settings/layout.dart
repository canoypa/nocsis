import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/pages/settings/sign_in.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/templates/drawer_layout.dart';

class SettingsShellRoute extends ShellRouteData {
  const SettingsShellRoute();

  @override
  Page<void> pageBuilder(
      BuildContext context, GoRouterState state, Widget navigator) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: SettingsLayout(
        child: navigator,
      ),
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

class SettingsLayout extends StatelessWidget {
  final Widget child;

  const SettingsLayout({
    super.key,
    required this.child,
  });

  static final Map<String, int> _routeToIndex = {
    const SettingsTopRoute().location: 0,
    const SettingsSignInRoute().location: 1,
  };

  int _getNavigationIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return _routeToIndex[location] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DrawerLayout(
      title: const Text('設定'),
      navigationIndex: _getNavigationIndex(context),
      onDestinationSelected: (value) {
        final route = _routeToIndex.entries
            .firstWhere((entry) => entry.value == value)
            .key;
        GoRouter.of(context).go(route);
      },
      navigationItems: const [
        NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('一般'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.vpn_key_outlined),
          selectedIcon: Icon(Icons.vpn_key),
          label: Text('サインイン'),
        ),
      ],
      child: child,
    );
  }
}
