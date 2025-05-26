part of 'package:nocsis/routes/router.dart';

const groupShellRoute = TypedShellRoute<GroupShellRoute>(
  routes: [
    classroomPageRoute,
    consoleShellRoute,
    personalShellRoute,
    settingsShellRoute,
  ],
);

class GroupShellRoute extends ShellRouteData {
  const GroupShellRoute();

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    final groupId = state.pathParameters['groupId']!;

    return CustomTransitionPage(
      key: state.pageKey,
      child: GroupLayout(groupId: groupId, navigator: navigator),
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
