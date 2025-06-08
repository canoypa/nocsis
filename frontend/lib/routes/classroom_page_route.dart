part of 'package:nocsis/routes/router.dart';

const classroomPageRoute = TypedGoRoute<ClassroomPageRoute>(
  path: ClassroomPageRoute.path,
);

class ClassroomPageRoute extends GoRouteData with _$ClassroomPageRoute {
  static const path = '/groups/:groupId/classroom';

  final String groupId;

  const ClassroomPageRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ClassroomPage(),
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
