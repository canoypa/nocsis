import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleWeatherRoute extends GoRouteData {
  const ConsoleWeatherRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleWeatherPage(),
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

class ConsoleWeatherPage extends StatelessWidget {
  const ConsoleWeatherPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('console - weather');
  }
}
