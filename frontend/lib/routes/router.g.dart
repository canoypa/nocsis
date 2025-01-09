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
          path: '/sign_in',
          factory: $SignInRouteExtension._fromState,
        ),
        ShellRouteData.$route(
          factory: $PersonalShellExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/',
              factory: $PersonalHomeRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/events',
              factory: $PersonalEventsRouteExtension._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: '/classroom',
          factory: $ClassroomRouteExtension._fromState,
        ),
        ShellRouteData.$route(
          factory: $ConsoleShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/console',
              factory: $ConsoleTopRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/group',
              factory: $ConsoleGroupRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/member',
              factory: $ConsoleMemberRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/calendar',
              factory: $ConsoleCalendarRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/day_duty',
              factory: $ConsoleDayDutyRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/weather',
              factory: $ConsoleWeatherRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/console/slack',
              factory: $ConsoleSlackRouteExtension._fromState,
            ),
          ],
        ),
        ShellRouteData.$route(
          factory: $SettingsShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/settings',
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

  String get location => GoRouteData.$location(
        '/sign_in',
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
        '/',
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
        '/events',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ClassroomRouteExtension on ClassroomRoute {
  static ClassroomRoute _fromState(GoRouterState state) =>
      const ClassroomRoute();

  String get location => GoRouteData.$location(
        '/classroom',
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
      const ConsoleTopRoute();

  String get location => GoRouteData.$location(
        '/console',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleGroupRouteExtension on ConsoleGroupRoute {
  static ConsoleGroupRoute _fromState(GoRouterState state) =>
      const ConsoleGroupRoute();

  String get location => GoRouteData.$location(
        '/console/group',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleMemberRouteExtension on ConsoleMemberRoute {
  static ConsoleMemberRoute _fromState(GoRouterState state) =>
      const ConsoleMemberRoute();

  String get location => GoRouteData.$location(
        '/console/member',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleCalendarRouteExtension on ConsoleCalendarRoute {
  static ConsoleCalendarRoute _fromState(GoRouterState state) =>
      const ConsoleCalendarRoute();

  String get location => GoRouteData.$location(
        '/console/calendar',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleDayDutyRouteExtension on ConsoleDayDutyRoute {
  static ConsoleDayDutyRoute _fromState(GoRouterState state) =>
      const ConsoleDayDutyRoute();

  String get location => GoRouteData.$location(
        '/console/day_duty',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleWeatherRouteExtension on ConsoleWeatherRoute {
  static ConsoleWeatherRoute _fromState(GoRouterState state) =>
      const ConsoleWeatherRoute();

  String get location => GoRouteData.$location(
        '/console/weather',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleSlackRouteExtension on ConsoleSlackRoute {
  static ConsoleSlackRoute _fromState(GoRouterState state) =>
      const ConsoleSlackRoute();

  String get location => GoRouteData.$location(
        '/console/slack',
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
      const SettingsTopRoute();

  String get location => GoRouteData.$location(
        '/settings',
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
