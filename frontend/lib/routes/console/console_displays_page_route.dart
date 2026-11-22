part of 'package:nocsis/routes/router.dart';

@Dependencies([currentGroupId])
const consoleDisplaysPageRoute = TypedGoRoute<ConsoleDisplaysPageRoute>(
  path: ConsoleDisplaysPageRoute.path,
);

@Dependencies([currentGroupId])
class ConsoleDisplaysPageRoute extends GoRouteData
    with $ConsoleDisplaysPageRoute {
  static const path = '/groups/:groupId/console/displays';

  final String groupId;

  const ConsoleDisplaysPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleDisplaysPage(),
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
