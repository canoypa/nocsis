part of 'package:nocsis/routes/router.dart';

const consoleGroupPageRoute = TypedGoRoute<ConsoleGroupPageRoute>(
  path: ConsoleGroupPageRoute.path,
);

class ConsoleGroupPageRoute extends GoRouteData {
  static const path = '/groups/:groupId/console/group';

  final String groupId;

  const ConsoleGroupPageRoute(this.groupId);

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
