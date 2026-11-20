import 'package:chopper/chopper.dart' as chopper;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/me.dart';

import '../helpers/mock_api_client.dart';

void main() {
  late MockApi mockApi;
  late ProviderContainer container;

  setUp(() {
    mockApi = MockApi();
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith((ref) async => mockApi),
        authProvider.overrideWith((ref) => Stream.value(MockUser(uid: 'u1'))),
      ],
      // Riverpod 3.x は失敗時にリトライするので、即座に AsyncError へ落とす
      retry: (_, _) => null,
    );
  });

  tearDown(() => container.dispose());

  // 認証状態の最初の値が来るまでは uid が無く、空を返す
  Future<void> waitForAuth(ProviderContainer container) async {
    container.listen(authProvider, (_, _) {});
    await container.read(authProvider.future);
  }

  test('ログインしていなければ API を呼ばずに空を返す', () async {
    final signedOut = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith((ref) async => mockApi),
        authProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(signedOut.dispose);

    await waitForAuth(signedOut);

    expect(await signedOut.read(meProvider.future), const Me(memberships: []));
    verifyNever(() => mockApi.apiV1MeGet());
  });

  group('groupPermissionsProvider', () {
    test('そのグループの権限だけを返す', () async {
      when(() => mockApi.apiV1MeGet()).thenAnswer(
        (_) async => chopper.Response(
          http.Response('', 200),
          const Me(
            memberships: [
              Membership(
                group: MembershipGroup(id: 'g1', name: 'A'),
                permissions: [Permission.groupRead, Permission.groupUpdate],
              ),
              Membership(
                group: MembershipGroup(id: 'g2', name: 'B'),
                permissions: [Permission.groupRead],
              ),
            ],
          ),
        ),
      );

      await waitForAuth(container);

      expect(await container.read(groupPermissionsProvider('g2').future), {
        Permission.groupRead,
      });
      expect(
        await container.read(groupPermissionsProvider('g3').future),
        isEmpty,
      );
    });

    test('API が失敗を返したら例外を投げる', () async {
      when(() => mockApi.apiV1MeGet()).thenAnswer(
        (_) async => chopper.Response<Me>(http.Response('', 500), null),
      );

      await waitForAuth(container);

      await expectLater(
        container.read(groupPermissionsProvider('g1').future),
        throwsException,
      );
    });
  });
}
