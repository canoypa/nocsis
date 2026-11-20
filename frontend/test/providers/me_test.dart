import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/me.dart';

import '../helpers/mock_api_client.dart';

void main() {
  late MockApi mockApi;
  late ProviderContainer container;

  setUp(() {
    mockApi = MockApi();
    container = ProviderContainer(
      overrides: [apiClientProvider.overrideWith((ref) async => mockApi)],
      // 取り直し続ける設定なので、テストでは即座に AsyncError へ落とす
      retry: (_, _) => null,
    );
  });

  tearDown(() => container.dispose());

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

      expect(
        await container.read(groupPermissionsProvider('u1', 'g2').future),
        {Permission.groupRead},
      );
      expect(
        await container.read(groupPermissionsProvider('u1', 'g3').future),
        isEmpty,
      );
    });

    test('API が失敗を返したら例外を投げる', () async {
      when(() => mockApi.apiV1MeGet()).thenAnswer(
        (_) async => chopper.Response<Me>(http.Response('', 500), null),
      );

      await expectLater(
        container.read(groupPermissionsProvider('u1', 'g1').future),
        throwsException,
      );
    });
  });
}
