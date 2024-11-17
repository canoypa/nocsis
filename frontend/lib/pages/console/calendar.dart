import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleCalendarRoute extends GoRouteData {
  const ConsoleCalendarRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleCalendarPage(),
    );
  }
}

class ConsoleCalendarPage extends StatelessWidget {
  const ConsoleCalendarPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - calendar');
  }
}
