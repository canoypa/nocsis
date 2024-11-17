import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleTopRoute extends GoRouteData {
  const ConsoleTopRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleTopPage(),
    );
  }
}

class ConsoleTopPage extends StatelessWidget {
  const ConsoleTopPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - home');
  }
}
