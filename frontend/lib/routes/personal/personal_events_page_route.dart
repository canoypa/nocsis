part of 'package:nocsis/routes/router.dart';

const personalEventsPageRoute = TypedGoRoute<PersonalEventsPageRoute>(
  path: PersonalEventsPageRoute.path,
);

class PersonalEventsPageRoute extends GoRouteData {
  final String groupId;

  static const path = '/groups/:groupId/events';

  const PersonalEventsPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return CustomTransitionPage(
      key: state.pageKey,
      child: const EventsView(),
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
