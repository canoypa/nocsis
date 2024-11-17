import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleGroupRoute extends GoRouteData {
  const ConsoleGroupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleGroupPage(),
    );
  }
}

class ConsoleGroupPage extends StatelessWidget {
  const ConsoleGroupPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - group');
  }
}
