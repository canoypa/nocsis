import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/providers/me.dart';
import 'package:nocsis/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テストでは画像を取りに行けないので、アイコンの画像を持たない人にする
// ignore: must_be_immutable
class _UserWithoutPhoto extends MockUser {
  _UserWithoutPhoto() : super(uid: 'u1', email: 'taro@example.com');

  @override
  String? get photoURL => null;
}

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
    MockFirebaseAuth auth, {
    Me? me,
  }) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = location;
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        if (me != null)
          meProvider(auth.currentUser!.uid).overrideWith((ref) async => me),
        // 教室の画面の時計は、止められない待ちで回り続ける
        for (final format in ['* * * * *', '*/15 * * * *', '0 0 * * *'])
          cronProvider(format).overrideWith((ref) => const Stream.empty()),
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

  group('端末の匿名アカウント', () {
    final device = MockUser(uid: 'd1', isAnonymous: true);
    const registered = Me(
      memberships: [
        Membership(
          group: MembershipGroup(id: 'g1', name: 'グループ'),
          permissions: [Permission.groupRead, Permission.memberRead],
        ),
      ],
    );

    for (final location in ['/', '/groups/g1', '/groups/g1/settings']) {
      testWidgets('登録前に $location を開くと、登録を待つ画面に戻す', (tester) async {
        final container = await pumpRouter(
          tester,
          location,
          MockFirebaseAuth(signedIn: true, mockUser: device),
          me: const Me(memberships: []),
        );
        await tester.pump();

        expect(currentLocation(container), '/display');
      });

      testWidgets('登録後に $location を開くと、教室の画面に戻す', (tester) async {
        final container = await pumpRouter(
          tester,
          location,
          MockFirebaseAuth(signedIn: true, mockUser: device),
          me: registered,
        );
        await tester.pump();

        expect(currentLocation(container), '/groups/g1/classroom');
      });
    }

    testWidgets('QR コードから開いた登録画面は、ログインしてから開く', (tester) async {
      final container = await pumpRouter(
        tester,
        '/display/register?code=123456',
        MockFirebaseAuth(signedIn: true, mockUser: device),
      );
      await tester.pump();

      expect(
        Uri.parse(currentLocation(container)).queryParameters['continue-uri'],
        '/display/register?code=123456',
      );
    });
  });

  group('設定のダイアログ', () {
    const member = Me(
      memberships: [
        Membership(
          group: MembershipGroup(id: 'g1', name: 'グループ'),
          permissions: [Permission.groupRead],
        ),
      ],
    );

    Future<ProviderContainer> openEmailDialog(WidgetTester tester) async {
      final container = await pumpRouter(
        tester,
        '/groups/g1/settings/email',
        MockFirebaseAuth(signedIn: true, mockUser: _UserWithoutPhoto()),
        me: member,
      );
      await tester.pump(const Duration(seconds: 1));
      return container;
    }

    testWidgets('URL で開いたダイアログに、そのまま留まる', (tester) async {
      final container = await openEmailDialog(tester);

      expect(currentLocation(container), '/groups/g1/settings/email');
      expect(find.text('メールアドレスを変更する'), findsWidgets);
    });

    testWidgets('ブラウザの戻るで設定の URL に戻ると、ダイアログが閉じる', (tester) async {
      final container = await openEmailDialog(tester);

      container.read(routerProvider).go('/groups/g1/settings');
      await tester.pumpAndSettle();

      expect(find.text('メールアドレスを変更する'), findsNothing);
      expect(find.text('設定'), findsWidgets);
    });
  });
}
