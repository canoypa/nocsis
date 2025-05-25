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
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final groupId = state.pathParameters['groupId']!;
    return GroupLayout(groupId: groupId, navigator: navigator);
  }
}
