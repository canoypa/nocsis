part of 'package:nocsis/routes/router.dart';

const consoleMemberPageRoute = TypedGoRoute<ConsoleMemberPageRoute>(
  path: ConsoleMemberPageRoute.path,
);

class ConsoleMemberPageRoute extends GoRouteData with _$ConsoleMemberPageRoute {
  static const path = '/groups/:groupId/console/member';

  final String groupId;

  const ConsoleMemberPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleMemberPage(),
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
