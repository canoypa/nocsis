part of 'package:nocsis/routes/router.dart';

const displayPageRoute = TypedGoRoute<DisplayPageRoute>(
  path: DisplayPageRoute.path,
  routes: [TypedGoRoute<DisplayRegisterPageRoute>(path: 'register')],
);

class DisplayPageRoute extends GoRouteData with $DisplayPageRoute {
  static const path = '/display';

  const DisplayPageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const DisplayPairingPage(),
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

class DisplayRegisterPageRoute extends GoRouteData
    with $DisplayRegisterPageRoute {
  /// 手で URL を打つと抜けることがある
  final String? code;

  const DisplayRegisterPageRoute({this.code});

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      code == null ? const TopPageRoute().location : null;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: DisplayRegisterPage(code: code ?? ''),
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
