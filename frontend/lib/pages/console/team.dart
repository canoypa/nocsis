import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleGroupRoute extends GoRouteData {
  const ConsoleGroupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleGroupPage(),
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

class ConsoleGroupPage extends StatelessWidget {
  const ConsoleGroupPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - group');
  }
}
