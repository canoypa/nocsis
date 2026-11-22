import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/displays.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/current_group_id.dart';

import '../helpers/mock_api_client.dart';

chopper.Response<T> _response<T>(int status, [T? body]) =>
    chopper.Response(http.Response('', status), body);

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
  });

  setUp(() {
    mockApi = MockApi();
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1')).thenAnswer(
      (_) async => _response(200, Displays(items: [active, removed])),
    );
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          apiClientProvider.overrideWith((ref) async => mockApi),
        ],
        retry: (_, _) => null,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ConsoleDisplaysPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('登録が解除された端末は、そうと分かるように出す', (tester) async {
    await pumpPage(tester);

    expect(find.text('1年1組 黒板横'), findsOneWidget);
    expect(find.text('3年2組 後方'), findsOneWidget);
    expect(find.text('登録が解除されています。使うときは端末で登録し直してください。'), findsOneWidget);
    expect(find.byTooltip('登録を解除'), findsOneWidget);
    expect(find.byTooltip('閉じる'), findsOneWidget);
  });

  testWidgets('1台も無いときも、一覧の場所を出す', (tester) async {
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1'))
        .thenAnswer((_) async => _response(200, const Displays(items: [])));
    await pumpPage(tester);

    expect(find.text('登録済みの端末'), findsOneWidget);
    expect(find.text('まだありません。'), findsOneWidget);
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
    await tester.enterText(find.widgetWithText(TextField, '名前'), ' 2年3組 前方 ');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, '登録'));
    await tester.pumpAndSettle();

    verify(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: const DisplayCreateJson(code: '123456', name: '2年3組 前方'),
      ),
    ).called(1);
    expect(find.text('コードが違うか、期限が切れています。ディスプレイのコードを確かめてください。'), findsOneWidget);
  });
}
