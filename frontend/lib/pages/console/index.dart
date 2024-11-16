import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleRoute extends GoRouteData {
  const ConsoleRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: SizedBox(
        height: 3000,
        child: const Text('console'),
      ),
    );
  }
}
