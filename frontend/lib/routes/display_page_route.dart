part of 'package:nocsis/routes/router.dart';

const displayPageRoute = TypedGoRoute<DisplayPageRoute>(
  path: DisplayPageRoute.path,
);

// 子にすると下に待ち受けの画面も積まれ、人のアカウントはそこでトップへ戻される
const displayRegisterPageRoute = TypedGoRoute<DisplayRegisterPageRoute>(
  path: DisplayRegisterPageRoute.path,
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
  static const path = '/display/register';

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
