part of 'package:nocsis/routes/router.dart';

const licensesPageRoute = TypedGoRoute<LicensesPageRoute>(
  path: LicensesPageRoute.path,
);

class LicensesPageRoute extends GoRouteData {
  static const path = '/licenses';

  const LicensesPageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const LicensesPage(),
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
