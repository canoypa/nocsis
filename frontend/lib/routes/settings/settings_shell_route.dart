part of 'package:nocsis/routes/router.dart';

const settingsShellRoute = TypedShellRoute<SettingsShellRoute>(
  routes: [settingsTopPageRoute],
);

class SettingsShellRoute extends ShellRouteData {
  const SettingsShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: SettingsLayout(child: navigator),
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
