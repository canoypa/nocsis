import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleCalendarRoute extends GoRouteData {
  const ConsoleCalendarRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleCalendarPage(),
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

class ConsoleCalendarPage extends StatelessWidget {
  const ConsoleCalendarPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - calendar');
  }
}
