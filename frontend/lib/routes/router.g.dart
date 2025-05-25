// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$appShell];

RouteBase get $appShell => ShellRouteData.$route(
  factory: $AppShellExtension._fromState,
  routes: [
    ShellRouteData.$route(
      factory: $GroupShellRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/groups/:groupId/classroom',

          factory: $ClassroomPageRouteExtension._fromState,
        ),
        ShellRouteData.$route(
          factory: $ConsoleShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/groups/:groupId/console',

              factory: $ConsoleTopPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/group',

              factory: $ConsoleGroupPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/member',

              factory: $ConsoleMemberPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/calendar',

              factory: $ConsoleCalendarPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/day_duty',

              factory: $ConsoleDayDutyPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/weather',

              factory: $ConsoleWeatherPageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/console/slack',

              factory: $ConsoleSlackPageRouteExtension._fromState,
            ),
          ],
        ),
        ShellRouteData.$route(
          factory: $PersonalShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/groups/:groupId',

              factory: $PersonalHomePageRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/groups/:groupId/events',

              factory: $PersonalEventsPageRouteExtension._fromState,
            ),
          ],
        ),
        ShellRouteData.$route(
          factory: $SettingsShellRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/groups/:groupId/settings',

              factory: $SettingsTopPageRouteExtension._fromState,
            ),
          ],
        ),
      ],
    ),
    GoRouteData.$route(
      path: '/licenses',

      factory: $LicensesPageRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: '/login',

      factory: $LoginPageRouteExtension._fromState,
    ),
  ],
);

extension $AppShellExtension on AppShell {
  static AppShell _fromState(GoRouterState state) => AppShell();
}

extension $GroupShellRouteExtension on GroupShellRoute {
  static GroupShellRoute _fromState(GoRouterState state) =>
      const GroupShellRoute();
}

extension $ClassroomPageRouteExtension on ClassroomPageRoute {
  static ClassroomPageRoute _fromState(GoRouterState state) =>
      ClassroomPageRoute(state.pathParameters['groupId']!);

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

extension $ConsoleTopPageRouteExtension on ConsoleTopPageRoute {
  static ConsoleTopPageRoute _fromState(GoRouterState state) =>
      ConsoleTopPageRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/console');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleGroupPageRouteExtension on ConsoleGroupPageRoute {
  static ConsoleGroupPageRoute _fromState(GoRouterState state) =>
      ConsoleGroupPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/group',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleMemberPageRouteExtension on ConsoleMemberPageRoute {
  static ConsoleMemberPageRoute _fromState(GoRouterState state) =>
      ConsoleMemberPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/member',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleCalendarPageRouteExtension on ConsoleCalendarPageRoute {
  static ConsoleCalendarPageRoute _fromState(GoRouterState state) =>
      ConsoleCalendarPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/calendar',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleDayDutyPageRouteExtension on ConsoleDayDutyPageRoute {
  static ConsoleDayDutyPageRoute _fromState(GoRouterState state) =>
      ConsoleDayDutyPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/day_duty',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleWeatherPageRouteExtension on ConsoleWeatherPageRoute {
  static ConsoleWeatherPageRoute _fromState(GoRouterState state) =>
      ConsoleWeatherPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/weather',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ConsoleSlackPageRouteExtension on ConsoleSlackPageRoute {
  static ConsoleSlackPageRoute _fromState(GoRouterState state) =>
      ConsoleSlackPageRoute(state.pathParameters['groupId']!);

  String get location => GoRouteData.$location(
    '/groups/${Uri.encodeComponent(groupId)}/console/slack',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonalShellRouteExtension on PersonalShellRoute {
  static PersonalShellRoute _fromState(GoRouterState state) =>
      const PersonalShellRoute();
}

extension $PersonalHomePageRouteExtension on PersonalHomePageRoute {
  static PersonalHomePageRoute _fromState(GoRouterState state) =>
      PersonalHomePageRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PersonalEventsPageRouteExtension on PersonalEventsPageRoute {
  static PersonalEventsPageRoute _fromState(GoRouterState state) =>
      PersonalEventsPageRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/events');

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

extension $SettingsTopPageRouteExtension on SettingsTopPageRoute {
  static SettingsTopPageRoute _fromState(GoRouterState state) =>
      SettingsTopPageRoute(state.pathParameters['groupId']!);

  String get location =>
      GoRouteData.$location('/groups/${Uri.encodeComponent(groupId)}/settings');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LicensesPageRouteExtension on LicensesPageRoute {
  static LicensesPageRoute _fromState(GoRouterState state) =>
      const LicensesPageRoute();

  String get location => GoRouteData.$location('/licenses');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $LoginPageRouteExtension on LoginPageRoute {
  static LoginPageRoute _fromState(GoRouterState state) => LoginPageRoute(
    continueUri: _$convertMapValue(
      'continue-uri',
      state.uri.queryParameters,
      Uri.tryParse,
    ),
  );

  String get location => GoRouteData.$location(
    '/login',
    queryParams: {
      if (continueUri != null) 'continue-uri': continueUri!.toString(),
    },
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
