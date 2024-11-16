import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return DrawerLayout(child: child);
  }
}
