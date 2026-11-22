import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('未ログインで保護ページを開くとログイン画面へ直接遷移する', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/groups/test-group/console';

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: false),
        ),
      ],
    );

    addTearDown(container.dispose);
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

    expect(find.text('管理コンソール'), findsNothing);

    await tester.pump();

    expect(
      container
          .read(routerProvider)
          .routeInformationProvider
          .value
          .uri
          .toString(),
      startsWith('/login?continue-uri='),
    );
    expect(find.text('ログイン'), findsWidgets);
    expect(find.text('Google で続行'), findsOneWidget);
    expect(find.text('管理コンソール'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('ログイン'), findsWidgets);
    expect(find.text('Google で続行'), findsOneWidget);
    expect(find.text('管理コンソール'), findsNothing);
  });

  Future<ProviderContainer> pumpRouter(
    WidgetTester tester,
    String location,
    MockFirebaseAuth auth,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = location;
    final container = ProviderContainer(
      overrides: [firebaseAuthProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);
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
    await tester.pump();

    return container;
  }

  String currentLocation(ProviderContainer container) => container
      .read(routerProvider)
      .routeInformationProvider
      .value
      .uri
      .toString();

  testWidgets('端末の匿名アカウントのままでも、ログイン画面を開ける', (tester) async {
    final container = await pumpRouter(
      tester,
      '/login',
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(isAnonymous: true)),
    );

    expect(currentLocation(container), '/login');
  });

  testWidgets('サインアウトされた端末は、登録を待つ画面に戻す', (tester) async {
    SharedPreferences.setMockInitialValues({'display_device': true});

    final container = await pumpRouter(
      tester,
      '/groups/g1/classroom',
      MockFirebaseAuth(signedIn: false),
    );

    expect(currentLocation(container), '/display');
  });

  testWidgets('QR コードから開いた登録画面に、そのまま留まる', (tester) async {
    SharedPreferences.setMockInitialValues({'latest_group_id': 'g1'});

    final container = await pumpRouter(
      tester,
      '/display/register?code=123456',
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(currentLocation(container), '/display/register?code=123456');
  });
}
