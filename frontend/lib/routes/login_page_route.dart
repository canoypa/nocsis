part of 'package:nocsis/routes/router.dart';

const loginPageRoute = TypedGoRoute<LoginPageRoute>(path: LoginPageRoute.path);

class LoginPageRoute extends GoRouteData with _$LoginPageRoute {
  static const path = '/login';

  final Uri? continueUri;

  const LoginPageRoute({this.continueUri});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const LoginPage(),
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
