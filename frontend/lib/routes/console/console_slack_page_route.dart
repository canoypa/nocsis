part of 'package:nocsis/routes/router.dart';

const consoleSlackPageRoute = TypedGoRoute<ConsoleSlackPageRoute>(
  path: ConsoleSlackPageRoute.path,
);

class ConsoleSlackPageRoute extends GoRouteData {
  static const path = '/groups/:groupId/console/slack';

  final String groupId;

  const ConsoleSlackPageRoute(this.groupId);

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
