import 'package:chopper/chopper.dart' as chopper;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_api_client.dart';

chopper.Response<T> _response<T>(int status, [T? body]) =>
    chopper.Response(http.Response('', status), body);

Group _group(String name) => Group(
  id: 'g1',
  name: name,
  classesCalendarId: 'classes',
  eventsCalendarId: 'events',
  daydutyStartDate: '2026-04-06',
  slackEventChannelId: '',
  weatherPoint: const WeatherPointOutput(lat: 0, lon: 0),
);

void main() {
  late MockApi mockApi;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const GroupPatchJson());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApi();
    when(() => mockApi.apiV1MeGet()).thenAnswer(
      (_) async => _response(
        200,
        Me(
          memberships: [
            Membership(
              group: const MembershipGroup(id: 'g1', name: '3年1組'),
              permissions: Permission.values.skip(1).toList(),
            ),
          ],
        ),
      ),
    );
    when(() => mockApi.apiV1GroupsIdGet(id: 'g1'))
        .thenAnswer((_) async => _response(200, _group('3年1組')));
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true),
        ),
        // モックユーザーのアバターは外部の画像で、テストでは読み込めずに失敗する
        authProvider.overrideWith((ref) => const Stream.empty()),
        apiClientProvider.overrideWith((ref) async => mockApi),
      ],
      retry: (_, _) => null,
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpApp(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = location;
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) =>
              MaterialApp.router(routerConfig: ref.watch(routerProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String currentLocation() => container
      .read(routerProvider)
      .routeInformationProvider
      .value
      .uri
      .toString();

  testWidgets('コンソールを開くと、グループ名を入力欄に出す', (tester) async {
    await pumpApp(tester, '/groups/g1/console');

    expect(currentLocation(), '/groups/g1/console');
    expect(find.widgetWithText(TextField, '3年1組'), findsOneWidget);
  });

  testWidgets('名前を変えるまでは保存できない', (tester) async {
    await pumpApp(tester, '/groups/g1/console');

    FilledButton save() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, '保存'));
    expect(save().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '3年2組');
    await tester.pump();
    expect(save().onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(save().onPressed, isNull);
  });

  testWidgets('保存すると、前後の空白を除いた名前を送り、保存したと出す', (tester) async {
    when(
      () => mockApi.apiV1GroupsIdPatch(
        id: 'g1',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {
      when(() => mockApi.apiV1GroupsIdGet(id: 'g1'))
          .thenAnswer((_) async => _response(200, _group('3年2組')));
      return _response(200, _group('3年2組'));
    });
    await pumpApp(tester, '/groups/g1/console');

    await tester.enterText(find.byType(TextField), ' 3年2組 ');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final body =
        verify(
              () => mockApi.apiV1GroupsIdPatch(
                id: 'g1',
                body: captureAny(named: 'body'),
              ),
            ).captured.single
            as GroupPatchJson;
    expect(body.name, '3年2組');
    expect(find.text('グループ名を保存しました。'), findsOneWidget);
    expect(find.widgetWithText(TextField, '3年2組'), findsOneWidget);
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '保存'),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('保存できなかったら、入力欄にそう出す', (tester) async {
    when(
      () => mockApi.apiV1GroupsIdPatch(
        id: 'g1',
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => _response(500));
    await pumpApp(tester, '/groups/g1/console');

    await tester.enterText(find.byType(TextField), '3年2組');
    await tester.pump();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('グループ名を保存できませんでした。'), findsOneWidget);
    expect(find.widgetWithText(TextField, '3年2組'), findsOneWidget);
  });

  testWidgets('読み込めなかったら、そう出す', (tester) async {
    when(() => mockApi.apiV1GroupsIdGet(id: 'g1'))
        .thenAnswer((_) async => _response(500));
    await pumpApp(tester, '/groups/g1/console');

    expect(find.text('グループを読み込めませんでした。'), findsOneWidget);
  });

  testWidgets('教室ディスプレイのダイアログの URL を開いても、ナビは教室ディスプレイを選んだままにする', (tester) async {
    when(() => mockApi.apiV1GroupsGroupIdDisplaysGet(groupId: 'g1'))
        .thenAnswer((_) async => _response(200, const Displays(items: [])));
    await pumpApp(tester, '/groups/g1/console/displays/register');

    expect(find.text('ディスプレイに表示されているコードを入力してください。'), findsOneWidget);
    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    final destinations = drawer.children
        .whereType<NavigationDrawerDestination>()
        .toList();
    final selected = destinations[drawer.selectedIndex!].label as Text;
    expect(selected.data, '教室ディスプレイ');
  });
}
