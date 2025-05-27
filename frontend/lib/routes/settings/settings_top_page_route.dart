part of 'package:nocsis/routes/router.dart';

const settingsTopPageRoute = TypedGoRoute<SettingsTopPageRoute>(
  path: SettingsTopPageRoute.path,
);

class SettingsTopPageRoute extends GoRouteData {
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
