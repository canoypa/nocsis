part of 'package:nocsis/routes/router.dart';

const consoleWeatherPageRoute = TypedGoRoute<ConsoleWeatherPageRoute>(
  path: ConsoleWeatherPageRoute.path,
);

class ConsoleWeatherPageRoute extends GoRouteData
    with _$ConsoleWeatherPageRoute {
  static const path = '/groups/:groupId/console/weather';

  final String groupId;

  const ConsoleWeatherPageRoute(this.groupId);

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
