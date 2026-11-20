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

void main() {
  late MockApi mockApi;
  late ProviderContainer container;

  late Me me;

  void givenPermissions(List<Permission> permissions) {
    me = Me(
      memberships: [
        Membership(
          group: const MembershipGroup(id: 'g1', name: 'グループ'),
          permissions: permissions,
        ),
      ],
    );
    when(() => mockApi.apiV1MeGet())
        .thenAnswer((_) async => chopper.Response(http.Response('', 200), me));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApi();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true),
        ),
        // モックユーザーのアバターは外部の画像で、テストでは読み込めずに失敗する。
        // アバターを読み込み中のままにして画像を取りに行かせない
        authProvider.overrideWith((ref) => const Stream.empty()),
        apiClientProvider.overrideWith((ref) async => mockApi),
      ],
      // 失敗時のリトライのタイマーがテストの後に残らないようにする
      retry: (_, _) => null,
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpApp(WidgetTester tester, String initialLocation) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        initialLocation;
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('group.update を持たない相手がコンソールの URL を開くと 404 を出す', (tester) async {
    givenPermissions([Permission.groupRead, Permission.memberRead]);

    await pumpApp(tester, '/groups/g1/console/group');

    expect(find.text('404: Page not found'), findsOneWidget);
    expect(find.text('管理コンソール'), findsNothing);
  });

  testWidgets('別のグループの権限ではコンソールを開けない', (tester) async {
    givenPermissions(Permission.values.toList());

    await pumpApp(tester, '/groups/g2/console');

    expect(find.text('404: Page not found'), findsOneWidget);
  });

  testWidgets('group.update を持つ相手はコンソールを開ける', (tester) async {
    givenPermissions([Permission.groupRead, Permission.groupUpdate]);

    await pumpApp(tester, '/groups/g1/console/group');

    expect(find.text('404: Page not found'), findsNothing);
    expect(find.text('管理コンソール'), findsWidgets);
  });

  testWidgets('メンバーを管理できない相手はメンバー画面を開けない', (tester) async {
    givenPermissions([Permission.groupRead, Permission.groupUpdate]);

    await pumpApp(tester, '/groups/g1/console/member');

    expect(find.text('404: Page not found'), findsOneWidget);
  });

  testWidgets('member.read を持たない相手が Classroom の URL を開くと 404 を出す', (
    tester,
  ) async {
    givenPermissions([Permission.groupRead]);

    await pumpApp(tester, '/groups/g1/classroom');

    expect(find.text('404: Page not found'), findsOneWidget);
  });

  String currentLocation() => container
      .read(routerProvider)
      .routeInformationProvider
      .value
      .uri
      .toString();

  testWidgets('開けない画面は 404 のページへ回す', (tester) async {
    givenPermissions([Permission.groupRead]);

    await pumpApp(tester, '/groups/g1/console');

    expect(currentLocation(), '/not-found');
  });

  testWidgets('開けないグループを覚えていたら忘れる（トップからまた飛ばされないように）', (tester) async {
    SharedPreferences.setMockInitialValues({'latest_group_id': 'g2'});
    givenPermissions(Permission.values.toList());

    await pumpApp(tester, '/groups/g2/console');

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('latest_group_id'), isNull);
  });

  testWidgets('開けないときは一度だけ取り直す（後から追加された直後のため）', (tester) async {
    givenPermissions([Permission.groupRead]);
    var calls = 0;
    when(() => mockApi.apiV1MeGet()).thenAnswer((_) async {
      calls++;
      return chopper.Response(
        http.Response('', 200),
        Me(
          memberships: [
            Membership(
              group: const MembershipGroup(id: 'g1', name: 'グループ'),
              permissions: calls == 1
                  ? [Permission.groupRead]
                  : Permission.values.toList(),
            ),
          ],
        ),
      );
    });

    await pumpApp(tester, '/groups/g1/console');

    expect(calls, 2);
    expect(currentLocation(), '/groups/g1/console');
  });

  testWidgets('権限が取れないときは通す（判定はサーバがする）', (tester) async {
    when(() => mockApi.apiV1MeGet()).thenAnswer(
      (_) async => chopper.Response<Me>(http.Response('', 500), null),
    );

    await pumpApp(tester, '/groups/g1/console');

    expect(currentLocation(), '/groups/g1/console');
  });
}
