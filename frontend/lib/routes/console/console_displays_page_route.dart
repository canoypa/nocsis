part of 'package:nocsis/routes/router.dart';

@Dependencies([currentGroupId])
const consoleDisplaysPageRoute = TypedGoRoute<ConsoleDisplaysPageRoute>(
  path: ConsoleDisplaysPageRoute.path,
  routes: [
    TypedGoRoute<RegisterDisplayDialogRoute>(
      path: RegisterDisplayDialogRoute.path,
    ),
    TypedGoRoute<RenameDisplayDialogRoute>(path: RenameDisplayDialogRoute.path),
    TypedGoRoute<RemoveDisplayDialogRoute>(path: RemoveDisplayDialogRoute.path),
  ],
);

@Dependencies([currentGroupId])
class ConsoleDisplaysPageRoute extends GoRouteData
    with $ConsoleDisplaysPageRoute {
  static const path = '/groups/:groupId/console/displays';

  final String groupId;

  const ConsoleDisplaysPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleDisplaysPage(),
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

class RegisterDisplayDialogRoute extends GoRouteData
    with $RegisterDisplayDialogRoute {
  static const path = 'register';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;

  const RegisterDisplayDialogRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      key: state.pageKey,
      builder: (_) => RegisterDisplayDialog(groupId: groupId),
    );
  }
}

class RenameDisplayDialogRoute extends GoRouteData
    with $RenameDisplayDialogRoute {
  static const path = ':displayId/name';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;
  final String displayId;

  const RenameDisplayDialogRoute(this.groupId, this.displayId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      key: state.pageKey,
      builder: (_) => ActiveDisplayBuilder(
        groupId: groupId,
        displayId: displayId,
        builder: (display) =>
            RenameDisplayDialog(groupId: groupId, display: display),
      ),
    );
  }
}

class RemoveDisplayDialogRoute extends GoRouteData
    with $RemoveDisplayDialogRoute {
  static const path = ':displayId/remove';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;
  final String displayId;

  const RemoveDisplayDialogRoute(this.groupId, this.displayId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      key: state.pageKey,
      builder: (_) => ActiveDisplayBuilder(
        groupId: groupId,
        displayId: displayId,
        builder: (display) =>
            RemoveDisplayDialog(groupId: groupId, display: display),
      ),
    );
  }
}
