part of 'package:nocsis/routes/router.dart';

const consoleDayDutyPageRoute = TypedGoRoute<ConsoleDayDutyPageRoute>(
  path: ConsoleDayDutyPageRoute.path,
);

class ConsoleDayDutyPageRoute extends GoRouteData
    with _$ConsoleDayDutyPageRoute {
  static const path = '/groups/:groupId/console/day_duty';

  final String groupId;

  const ConsoleDayDutyPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleDayDutyPage(),
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
