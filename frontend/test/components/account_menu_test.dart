import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
void main() {
  Future<void> openMenu(WidgetTester tester, Set<Permission> granted) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          currentUidProvider.overrideWithValue('u1'),
          groupPermissionsProvider(
            'u1',
            'g1',
          ).overrideWith((ref) async => granted),
          authProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: Scaffold(body: AccountMenu())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
  }

  testWidgets('group.update を持つ相手には管理コンソールを出す', (tester) async {
    await openMenu(tester, {Permission.groupRead, Permission.groupUpdate});

    expect(find.text('管理コンソール'), findsOneWidget);
  });

  testWidgets('閲覧だけの相手には管理コンソールも教室ディスプレイも出さない', (tester) async {
    await openMenu(tester, {Permission.groupRead});

    expect(find.text('管理コンソール'), findsNothing);
    expect(find.text('教室ディスプレイを表示'), findsNothing);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('教室ディスプレイには、表示だけを出す', (tester) async {
    await openMenu(tester, {Permission.groupRead, Permission.memberRead});

    expect(find.text('管理コンソール'), findsNothing);
    expect(find.text('教室ディスプレイを表示'), findsOneWidget);
  });

  testWidgets('admin には管理コンソールと教室ディスプレイの表示を出す', (tester) async {
    await openMenu(tester, Permission.values.toSet());

    expect(find.text('管理コンソール'), findsOneWidget);
    expect(find.text('教室ディスプレイを表示'), findsOneWidget);
  });

  testWidgets('項目を押すとメニューを閉じる', (tester) async {
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (_, _, child) => Scaffold(
            appBar: AppBar(actions: const [AccountMenu()]),
            body: child,
          ),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const SizedBox()),
            GoRoute(
              path: '/groups/:groupId/settings',
              builder: (_, _) => const SizedBox(),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          currentUidProvider.overrideWithValue('u1'),
          groupPermissionsProvider(
            'u1',
            'g1',
          ).overrideWith((ref) async => {Permission.groupRead}),
          authProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    expect(find.text('設定'), findsNothing);
  });
}
