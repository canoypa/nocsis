import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleMemberRoute extends GoRouteData {
  const ConsoleMemberRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleMemberPage(),
    );
  }
}

class ConsoleMemberPage extends StatelessWidget {
  const ConsoleMemberPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - member');
  }
}
