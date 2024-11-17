import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleSlackRoute extends GoRouteData {
  const ConsoleSlackRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleSlackPage(),
    );
  }
}

class ConsoleSlackPage extends StatelessWidget {
  const ConsoleSlackPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - slack');
  }
}
