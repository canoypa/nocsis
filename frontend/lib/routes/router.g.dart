// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $appShell,
    ];

RouteBase get $appShell => ShellRouteData.$route(
      factory: $AppShellExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/',
          factory: $HomeRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/signin',
          factory: $SignInRouteExtension._fromState,
        ),
        ShellRouteData.$route(
          factory: $PersonalShellExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/personal',
              factory: $PersonalHomeRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/personal/events',
              factory: $PersonalEventsRouteExtension._fromState,
            ),
          ],
        ),
        ShellRouteData.$route(
          factory: $ConsoleShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/console',
              factory: $ConsoleRouteExtension._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: '/licenses',
          factory: $LicensesRouteExtension._fromState,
        ),
      ],
    );

extension $AppShellExtension on AppShell {
  static AppShell _fromState(GoRouterState state) => AppShell();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SignInRouteExtension on SignInRoute {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  String get location => GoRouteData.$location(
        '/signin',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonalShellExtension on PersonalShell {
  static PersonalShell _fromState(GoRouterState state) => const PersonalShell();
}

extension $PersonalHomeRouteExtension on PersonalHomeRoute {
  static PersonalHomeRoute _fromState(GoRouterState state) =>
      const PersonalHomeRoute();

  String get location => GoRouteData.$location(
        '/personal',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonalEventsRouteExtension on PersonalEventsRoute {
  static PersonalEventsRoute _fromState(GoRouterState state) =>
      const PersonalEventsRoute();

  String get location => GoRouteData.$location(
        '/personal/events',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleShellRouteExtension on ConsoleShellRoute {
  static ConsoleShellRoute _fromState(GoRouterState state) =>
      const ConsoleShellRoute();
}

extension $ConsoleRouteExtension on ConsoleRoute {
  static ConsoleRoute _fromState(GoRouterState state) => const ConsoleRoute();

  String get location => GoRouteData.$location(
        '/console',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LicensesRouteExtension on LicensesRoute {
  static LicensesRoute _fromState(GoRouterState state) => const LicensesRoute();

  String get location => GoRouteData.$location(
        '/licenses',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
