import 'package:chopper/chopper.dart' as chopper;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_api_client.dart';

void main() {
  late MockApi mockApi;
  late MockFirebaseAuth auth;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApi();
    when(() => mockApi.apiV1UsersMeGroupsGet()).thenAnswer(
      (_) async => chopper.Response(
        http.Response('', 200),
        const UserJoinedGroups(items: []),
      ),
    );
    auth = MockFirebaseAuth(signedIn: true);
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        apiClientProvider.overrideWith((ref) async => mockApi),
      ],
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

  String currentLocation() => container
      .read(routerProvider)
      .routeInformationProvider
      .value
      .uri
      .toString();

  testWidgets('グループ未参加のユーザーがトップを開くとグループ未参加の画面へ遷移する', (tester) async {
    await pumpApp(tester, '/');

    expect(tester.takeException(), isNull);
    expect(currentLocation(), '/no-groups');
    expect(find.text('参加しているグループがありません'), findsOneWidget);
  });

  testWidgets('グループ未参加のユーザーがログイン画面を開くとグループ未参加の画面へ遷移する', (tester) async {
    await pumpApp(tester, '/login');

    expect(tester.takeException(), isNull);
    expect(currentLocation(), '/no-groups');
    expect(find.text('参加しているグループがありません'), findsOneWidget);
  });

  testWidgets('グループ未参加の画面からログアウトするとログイン画面へ遷移する', (tester) async {
    await pumpApp(tester, '/');

    await tester.tap(find.text('ログアウト'));
    await tester.pumpAndSettle();

    expect(auth.currentUser, isNull);
    expect(currentLocation(), '/login');
  });
}
