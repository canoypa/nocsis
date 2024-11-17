import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleSlackRoute extends GoRouteData {
  const ConsoleSlackRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleSlackPage(),
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

class ConsoleSlackPage extends StatelessWidget {
  const ConsoleSlackPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - slack');
  }
}
