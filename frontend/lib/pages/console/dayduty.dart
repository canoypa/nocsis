import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleDayDutyRoute extends GoRouteData {
  const ConsoleDayDutyRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleDayDutyPage(),
    );
  }
}

class ConsoleDayDutyPage extends StatelessWidget {
  const ConsoleDayDutyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - day duty');
  }
}
