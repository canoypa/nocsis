import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleDayDutyRoute extends GoRouteData {
  const ConsoleDayDutyRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleDayDutyPage(),
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

class ConsoleDayDutyPage extends StatelessWidget {
  const ConsoleDayDutyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - day duty');
  }
}
