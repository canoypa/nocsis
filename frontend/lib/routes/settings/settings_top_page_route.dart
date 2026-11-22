part of 'package:nocsis/routes/router.dart';

const settingsTopPageRoute = TypedGoRoute<SettingsTopPageRoute>(
  path: SettingsTopPageRoute.path,
  routes: [
    TypedGoRoute<ChangeEmailDialogRoute>(path: ChangeEmailDialogRoute.path),
    TypedGoRoute<ChangePasswordDialogRoute>(
      path: ChangePasswordDialogRoute.path,
    ),
    TypedGoRoute<ReplaceGoogleAccountDialogRoute>(
      path: ReplaceGoogleAccountDialogRoute.path,
    ),
  ],
);

class SettingsTopPageRoute extends GoRouteData with $SettingsTopPageRoute {
  static const path = '/groups/:groupId/settings';

  final String groupId;

  const SettingsTopPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const SettingsTopPage(),
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

class ChangeEmailDialogRoute extends GoRouteData with $ChangeEmailDialogRoute {
  static const path = 'email';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;

  const ChangeEmailDialogRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      key: state.pageKey,
      builder: (context) =>
          ChangeEmailDialog(onSubmit: () => Navigator.of(context).pop()),
    );
  }
}

class ChangePasswordDialogRoute extends GoRouteData
    with $ChangePasswordDialogRoute {
  static const path = 'password';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;

  const ChangePasswordDialogRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(
      key: state.pageKey,
      builder: (context) =>
          ChangePasswordDialog(onSubmit: () => Navigator.of(context).pop()),
    );
  }
}

/// 選んだ Google アカウントのアクセストークンを返して閉じる
class ReplaceGoogleAccountDialogRoute extends GoRouteData
    with $ReplaceGoogleAccountDialogRoute {
  static const path = 'google-account';
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  final String groupId;

  const ReplaceGoogleAccountDialogRoute(this.groupId);

  @override
  Page<String> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage<String>(
      key: state.pageKey,
      builder: (_) => const ReplaceGoogleAccountDialog(),
    );
  }
}
