part of 'package:nocsis/routes/router.dart';

const noGroupPageRoute = TypedGoRoute<NoGroupPageRoute>(
  path: NoGroupPageRoute.path,
);

class NoGroupPageRoute extends GoRouteData with $NoGroupPageRoute {
  static const path = '/no-groups';

  const NoGroupPageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const NoGroupPage(),
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
