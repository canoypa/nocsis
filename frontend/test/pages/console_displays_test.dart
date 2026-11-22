import 'dart:async';

import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/displays/page.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/routes/router.dart';

import '../helpers/mock_api_client.dart';

chopper.Response<T> _response<T>(int status, [T? body]) =>
    chopper.Response(http.Response('', status), body);

/// 教室ディスプレイの画面とダイアログのルートだけを持つルーター
GoRouter displaysRouter(String initialLocation) {
  GoRoute dialog(
    String path,
    GoRouteData Function(GoRouterState state) route,
  ) => GoRoute(
    path: path,
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => route(state).buildPage(context, state),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/groups/:groupId/console/displays',
        builder: (context, state) => ProviderScope(
          overrides: [currentGroupIdProvider.overrideWithValue('g1')],
          child: const Scaffold(
            body: SingleChildScrollView(child: ConsoleDisplaysPage()),
          ),
        ),
        routes: [
          dialog(
            RegisterDisplayDialogRoute.path,
            (_) => const RegisterDisplayDialogRoute('g1'),
          ),
          dialog(
            RenameDisplayDialogRoute.path,
            (state) => RenameDisplayDialogRoute(
              'g1',
              state.pathParameters['displayId']!,
            ),
          ),
          dialog(
            RemoveDisplayDialogRoute.path,
            (state) => RemoveDisplayDialogRoute(
              'g1',
              state.pathParameters['displayId']!,
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  late MockApi mockApi;

  final active = Display(
    id: 'd1',
    name: '1年1組 黒板横',
    createdAt: DateTime(2026, 11, 1),
    removedAt: null,
  );
  final removed = Display(
    id: 'd2',
    name: '3年2組 後方',
    createdAt: DateTime(2026, 10, 1),
    removedAt: DateTime(2026, 11, 20),
  );

  setUpAll(() {
    registerFallbackValue(const DisplayCreateJson(code: '', name: ''));
    registerFallbackValue(const DisplayPatchJson(name: ''));
  });

  setUp(() {
    mockApi = MockApi();
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1')).thenAnswer(
      (_) async => _response(200, Displays(items: [active, removed])),
    );
  });

  Future<GoRouter> pumpPage(
    WidgetTester tester, {
    String location = '/groups/g1/console/displays',
  }) async {
    final router = displaysRouter(location);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWith((ref) async => mockApi)],
        retry: (_, _) => null,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String currentLocation(GoRouter router) =>
      router.routeInformationProvider.value.uri.toString();

  testWidgets('登録が解除された端末は、そうと分かるように出す', (tester) async {
    await pumpPage(tester);

    expect(find.text('1年1組 黒板横'), findsOneWidget);
    expect(find.text('3年2組 後方'), findsOneWidget);
    expect(find.text('登録が解除されています。使うときは端末で登録し直してください。'), findsOneWidget);
    expect(find.byTooltip('登録を解除'), findsOneWidget);
    expect(find.byTooltip('閉じる'), findsOneWidget);
  });

  testWidgets('読み込み中は一覧の形のスケルトンを出し、読み込んだら端末に替える', (tester) async {
    final response = Completer<chopper.Response<Displays>>();
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1'))
        .thenAnswer((_) => response.future);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          apiClientProvider.overrideWith((ref) async => mockApi),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ConsoleDisplaysPage()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('読み込み中'), findsOneWidget);
    expect(find.text('1年1組 黒板横'), findsNothing);

    response.complete(_response(200, Displays(items: [active])));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('読み込み中'), findsNothing);
    expect(find.text('1年1組 黒板横'), findsOneWidget);
  });

  testWidgets('1台も無いときも、一覧の場所を出す', (tester) async {
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1'))
        .thenAnswer((_) async => _response(200, const Displays(items: [])));
    await pumpPage(tester);

    expect(find.text('登録済みの端末'), findsOneWidget);
    expect(find.text('まだありません。'), findsOneWidget);
  });

  testWidgets('端末で開く URL をコピーできる', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await pumpPage(tester);

    await tester.tap(find.byTooltip('URL をコピー'));
    await tester.pump();

    expect(copied, endsWith('/display'));
    expect(find.text('URL をコピーしました'), findsOneWidget);
  });

  testWidgets('確かめてから登録を解除する', (tester) async {
    when(
      () => mockApi.apiV1GroupsGroupIdDisplaysDisplayIdDelete(
        groupId: 'g1',
        displayId: 'd1',
      ),
    ).thenAnswer((_) async => _response(204));
    await pumpPage(tester);

    await tester.tap(find.byTooltip('登録を解除'));
    await tester.pumpAndSettle();
    expect(find.text('「1年1組 黒板横」の登録を解除しますか？'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '登録を解除'));
    await tester.pumpAndSettle();

    expect(find.text('「1年1組 黒板横」の登録を解除しますか？'), findsNothing);
    verify(
      () => mockApi.apiV1GroupsGroupIdDisplaysDisplayIdDelete(
        groupId: 'g1',
        displayId: 'd1',
      ),
    ).called(1);
  });

  testWidgets('コードが見つからなければ、ダイアログにそう出す', (tester) async {
    when(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => _response(404));
    await pumpPage(tester);

    await tester.tap(find.text('コードで登録'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'コード'), '123456');
    await tester.enterText(find.widgetWithText(TextField, '名前（任意）'), ' 前方 ');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, '登録'));
    await tester.pumpAndSettle();

    verify(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: const DisplayCreateJson(code: '123456', name: '前方'),
      ),
    ).called(1);
    expect(find.text('コードが違うか、期限が切れています。ディスプレイのコードを確かめてください。'), findsOneWidget);
  });

  testWidgets('名前は空のままでも登録できる', (tester) async {
    when(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => _response(201));
    await pumpPage(tester);

    await tester.tap(find.text('コードで登録'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'コード'), '123456');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, '登録'));
    await tester.pumpAndSettle();

    verify(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: const DisplayCreateJson(code: '123456', name: ''),
      ),
    ).called(1);
  });

  testWidgets('ダイアログは URL を変えずに開く', (tester) async {
    final router = await pumpPage(tester);

    await tester.tap(find.text('コードで登録'));
    await tester.pumpAndSettle();

    expect(currentLocation(router), '/groups/g1/console/displays');
    expect(find.text('ディスプレイに表示されているコードを入力してください。'), findsOneWidget);
  });

  for (final (path, text) in [
    ('register', 'ディスプレイに表示されているコードを入力してください。'),
    ('d1/name', '名前を変更'),
    ('d1/remove', '「1年1組 黒板横」の登録を解除しますか？'),
  ]) {
    testWidgets('/displays/$path を開くと、そのダイアログに留まる', (tester) async {
      final router = await pumpPage(
        tester,
        location: '/groups/g1/console/displays/$path',
      );

      expect(currentLocation(router), '/groups/g1/console/displays/$path');
      expect(find.text(text), findsOneWidget);
    });
  }

  testWidgets('名前を変えると、ダイアログを閉じて一覧に新しい名前を出す', (tester) async {
    when(
      () => mockApi.apiV1GroupsGroupIdDisplaysDisplayIdPatch(
        groupId: 'g1',
        displayId: 'd1',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {
      when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1'))
          .thenAnswer(
            (_) async => _response(
              200,
              Displays(
                items: [
                  active.copyWith(name: '前方'),
                  removed,
                ],
              ),
            ),
          );
      return _response(204);
    });
    await pumpPage(tester);

    await tester.tap(find.byTooltip('名前を変更'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '名前'), '前方');
    await tester.tap(find.widgetWithText(TextButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, '保存'), findsNothing);
    expect(find.text('前方'), findsOneWidget);
    expect(find.text('1年1組 黒板横'), findsNothing);
  });
}
