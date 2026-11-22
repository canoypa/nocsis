import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:nocsis/templates/drawer_layout.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    double height = 800,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Text('前の画面'),
          routes: [
            GoRoute(
              path: 'console',
              builder: (context, state) => ProviderScope(
                overrides: [currentGroupIdProvider.overrideWithValue('g1')],
                child: const _Console(),
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUidProvider.overrideWithValue('u1'),
          meProvider('u1')
              .overrideWith((ref) async => const Me(memberships: [])),
          groupPermissionsProvider('u1', 'g1').overrideWith((ref) async => {}),
          authProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/console');
    await tester.pumpAndSettle();
  }

  testWidgets('スマホの幅ではナビを隠し、メニューから開く', (tester) async {
    await pumpAt(tester, 400);

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('メンバー'), findsNothing);

    await tester.tap(find.byTooltip('メニュー'));
    await tester.pumpAndSettle();

    expect(find.text('メンバー'), findsOneWidget);
  });

  testWidgets('スマホの幅では、本文をアプリバーから 24 離す', (tester) async {
    await pumpAt(tester, 400);

    final appBar = tester.getRect(find.byType(AppBar));
    final body = tester.getRect(find.text('本文'));
    expect(body.top - appBar.bottom, 24);
  });

  testWidgets('スマホの幅でもメニューの戻る矢印で前の画面に戻れる', (tester) async {
    await pumpAt(tester, 400);

    await tester.tap(find.byTooltip('メニュー'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Symbols.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('前の画面'), findsOneWidget);
    expect(find.text('本文'), findsNothing);
  });

  testWidgets('タブレットの幅では rail を出す', (tester) async {
    await pumpAt(tester, 800);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byTooltip('メニュー'), findsNothing);
  });

  testWidgets('背の低い窓でも rail がはみ出さない', (tester) async {
    await pumpAt(tester, 800, height: 300);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('広い幅では開いたナビを出す', (tester) async {
    await pumpAt(tester, 1400);

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationDrawer), findsOneWidget);
  });
}

@Dependencies([currentGroupId])
class _Console extends StatelessWidget {
  const _Console();

  @override
  Widget build(BuildContext context) {
    return DrawerLayout(
      title: const Text('管理コンソール'),
      navigationIndex: 0,
      onDestinationSelected: (_) {},
      navigationItems: const [
        NavigationDrawerDestination(
          icon: Icon(Symbols.home),
          label: Text('ホーム'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Symbols.group),
          label: Text('メンバー'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Symbols.calendar_today),
          label: Text('カレンダー'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Symbols.wb_sunny),
          label: Text('気象データ連携'),
        ),
      ],
      child: const Text('本文'),
    );
  }
}
