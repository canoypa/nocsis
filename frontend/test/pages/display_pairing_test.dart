import 'package:chopper/chopper.dart' as chopper;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/display/pairing.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_api_client.dart';

chopper.Response<T> _response<T>(int status, [T? body]) =>
    chopper.Response(http.Response('', status), body);

void main() {
  late MockApi mockApi;
  late Me me;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApi();
    me = const Me(memberships: []);
    when(() => mockApi.apiV1MeGet())
        .thenAnswer((_) async => _response(200, me));
    when(() => mockApi.apiV1DisplayPairingsPost()).thenAnswer(
      (_) async => _response(
        201,
        DisplayPairing(
          code: '482913',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        ),
      ),
    );
  });

  Future<void> pumpPage(WidgetTester tester, MockFirebaseAuth auth) async {
    final router = GoRouter(
      initialLocation: '/display',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('トップ')),
        GoRoute(
          path: '/display',
          builder: (_, _) => const DisplayPairingPage(),
        ),
        GoRoute(
          path: '/groups/:groupId/classroom',
          builder: (_, state) => Text('教室 ${state.pathParameters['groupId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(auth),
          apiClientProvider.overrideWith((ref) async => mockApi),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('匿名でサインインしてコードを出し、登録されたら教室の画面に切り替わる', (tester) async {
    final auth = MockFirebaseAuth();
    await pumpPage(tester, auth);

    expect(auth.currentUser?.isAnonymous, isTrue);
    for (final digit in '482913'.split('')) {
      expect(find.text(digit), findsOneWidget);
    }

    me = const Me(
      memberships: [
        Membership(
          group: MembershipGroup(id: 'g1', name: '1年1組'),
          permissions: [Permission.groupRead],
        ),
      ],
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('教室 g1'), findsOneWidget);
  });

  testWidgets('人のアカウントでは、コードを出さずにトップへ戻す', (tester) async {
    await pumpPage(
      tester,
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(isAnonymous: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('トップ'), findsOneWidget);
    verifyNever(() => mockApi.apiV1DisplayPairingsPost());
  });
}
