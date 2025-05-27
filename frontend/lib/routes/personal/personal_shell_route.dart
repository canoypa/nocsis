part of 'package:nocsis/routes/router.dart';

const personalShellRoute = TypedShellRoute<PersonalShellRoute>(
  routes: [personalHomePageRoute, personalEventsPageRoute],
);

class PersonalShellRoute extends ShellRouteData {
  const PersonalShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: MainPage(navigationState: state, child: navigator),
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
