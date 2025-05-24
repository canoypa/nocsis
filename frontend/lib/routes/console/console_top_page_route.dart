part of 'package:nocsis/routes/router.dart';

const consoleTopPageRoute = TypedGoRoute<ConsoleTopPageRoute>(
  path: ConsoleTopPageRoute.path,
);

class ConsoleTopPageRoute extends GoRouteData {
  static const path = '/groups/:groupId/console';

  final String groupId;

  const ConsoleTopPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleTopPage(),
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
