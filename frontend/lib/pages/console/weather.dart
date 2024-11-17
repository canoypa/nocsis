import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleWeatherRoute extends GoRouteData {
  const ConsoleWeatherRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      key: state.pageKey,
      child: const ConsoleWeatherPage(),
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
