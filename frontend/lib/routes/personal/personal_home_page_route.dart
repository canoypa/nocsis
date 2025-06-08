part of 'package:nocsis/routes/router.dart';

const personalHomePageRoute = TypedGoRoute<PersonalHomePageRoute>(
  path: PersonalHomePageRoute.path,
);

class PersonalHomePageRoute extends GoRouteData with _$PersonalHomePageRoute {
  final String groupId;

  static const path = '/groups/:groupId';

  const PersonalHomePageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return CustomTransitionPage(
      key: state.pageKey,
      child: const MainView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (isMobile) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        }

        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}
