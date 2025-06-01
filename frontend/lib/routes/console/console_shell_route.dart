part of 'package:nocsis/routes/router.dart';

const consoleShellRoute = TypedShellRoute<ConsoleShellRoute>(
  routes: [
    consoleTopPageRoute,
    consoleGroupPageRoute,
    consoleMemberPageRoute,
    consoleCalendarPageRoute,
    consoleDayDutyPageRoute,
    consoleWeatherPageRoute,
    consoleSlackPageRoute,
  ],
);

class ConsoleShellRoute extends ShellRouteData {
  const ConsoleShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: ConsoleLayout(child: navigator),
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
