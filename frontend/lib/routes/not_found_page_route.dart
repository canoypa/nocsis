part of 'package:nocsis/routes/router.dart';

const notFoundPageRoute = TypedGoRoute<NotFoundPageRoute>(
  path: NotFoundPageRoute.path,
);

class NotFoundPageRoute extends GoRouteData with $NotFoundPageRoute {
  static const path = '/not-found';

  const NotFoundPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ErrorPage();
}
