part of 'package:nocsis/routes/router.dart';

const topPageRoute = TypedGoRoute<TopPageRoute>(path: TopPageRoute.path);

class TopPageRoute extends GoRouteData with $TopPageRoute {
  static const path = '/';

  const TopPageRoute();

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
