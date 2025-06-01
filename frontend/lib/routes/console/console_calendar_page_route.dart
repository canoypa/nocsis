part of 'package:nocsis/routes/router.dart';

const consoleCalendarPageRoute = TypedGoRoute<ConsoleCalendarPageRoute>(
  path: ConsoleCalendarPageRoute.path,
);

class ConsoleCalendarPageRoute extends GoRouteData {
  static const path = '/groups/:groupId/console/calendar';

  final String groupId;

  const ConsoleCalendarPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleCalendarPage(),
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
