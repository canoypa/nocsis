// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$appShell];

RouteBase get $appShell => ShellRouteData.$route(
  factory: $AppShellExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: '/sign_in',

      factory: $SignInRouteExtension._fromState,
    ),
    ShellRouteData.$route(
      factory: $PersonalShellExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/groups/:groupId',

          factory: $PersonalHomeRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/events',

          factory: $PersonalEventsRouteExtension._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: '/groups/:groupId/classroom',

      factory: $ClassroomRouteExtension._fromState,
    ),
    ShellRouteData.$route(
      factory: $ConsoleShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/groups/:groupId/console',

          factory: $ConsoleTopRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/group',

          factory: $ConsoleGroupRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/member',

          factory: $ConsoleMemberRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/calendar',

          factory: $ConsoleCalendarRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/day_duty',

          factory: $ConsoleDayDutyRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/weather',

          factory: $ConsoleWeatherRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/groups/:groupId/console/slack',

          factory: $ConsoleSlackRouteExtension._fromState,
        ),
      ],
    ),
    ShellRouteData.$route(
      factory: $SettingsShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/groups/:groupId/settings',

          factory: $SettingsTopRouteExtension._fromState,
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

extension $SignInRouteExtension on SignInRoute {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  String get location => GoRouteData.$location('/sign_in');

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
      PersonalHomeRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonalEventsRouteExtension on PersonalEventsRoute {
  static PersonalEventsRoute _fromState(GoRouterState state) =>
      PersonalEventsRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/events');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ClassroomRouteExtension on ClassroomRoute {
  static ClassroomRoute _fromState(GoRouterState state) =>
      ClassroomRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/classroom',
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

extension $ConsoleTopRouteExtension on ConsoleTopRoute {
  static ConsoleTopRoute _fromState(GoRouterState state) =>
      ConsoleTopRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/console');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleGroupRouteExtension on ConsoleGroupRoute {
  static ConsoleGroupRoute _fromState(GoRouterState state) =>
      ConsoleGroupRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/group',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleMemberRouteExtension on ConsoleMemberRoute {
  static ConsoleMemberRoute _fromState(GoRouterState state) =>
      ConsoleMemberRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/member',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleCalendarRouteExtension on ConsoleCalendarRoute {
  static ConsoleCalendarRoute _fromState(GoRouterState state) =>
      ConsoleCalendarRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/calendar',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleDayDutyRouteExtension on ConsoleDayDutyRoute {
  static ConsoleDayDutyRoute _fromState(GoRouterState state) =>
      ConsoleDayDutyRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/day_duty',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleWeatherRouteExtension on ConsoleWeatherRoute {
  static ConsoleWeatherRoute _fromState(GoRouterState state) =>
      ConsoleWeatherRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/weather',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleSlackRouteExtension on ConsoleSlackRoute {
  static ConsoleSlackRoute _fromState(GoRouterState state) =>
      ConsoleSlackRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/slack',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingsShellRouteExtension on SettingsShellRoute {
  static SettingsShellRoute _fromState(GoRouterState state) =>
      const SettingsShellRoute();
}

extension $SettingsTopRouteExtension on SettingsTopRoute {
  static SettingsTopRoute _fromState(GoRouterState state) =>
      SettingsTopRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/settings');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LicensesRouteExtension on LicensesRoute {
  static LicensesRoute _fromState(GoRouterState state) => const LicensesRoute();

  String get location => GoRouteData.$location('/licenses');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
