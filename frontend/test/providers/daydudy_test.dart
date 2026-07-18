import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/daydudy.dart';

import '../helpers/mock_api_client.dart';

void main() {
  group('daydudyProvider', () {
    late MockApi mockApi;

    setUp(() {
      mockApi = MockApi();
    });

    test('日直情報を取得できる', () async {
      // Arrange
      final classmate = Classmate(
        role: ClassmateRole.student,
        stuNo: 1,
        name: 'テスト太郎',
        email: 'test@example.com',
        slackUserId: 'U123',
      );
      when(
        () => mockApi.apiV1GroupsGroupIdDaydutyGet(
          groupId: 'group-1',
          date: any(named: 'date'),
        ),
      ).thenAnswer(
        (_) async => chopper.Response(http.Response('', 200), classmate),
      );

      final container = ProviderContainer(
        overrides: [overrideApiClient(mockApi)],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(daydudyProvider('group-1').future);

      // Assert
      expect(result, classmate);
    });

    test('APIが失敗を返した場合は例外を投げる', () async {
      // Arrange
      when(
        () => mockApi.apiV1GroupsGroupIdDaydutyGet(
          groupId: 'group-1',
          date: any(named: 'date'),
        ),
      ).thenAnswer(
        (_) async => chopper.Response<Classmate>(http.Response('', 500), null),
      );

      // Riverpod 3.x はデフォルトで失敗時にリトライするため、
      // リトライを無効化して即座に AsyncError へ落とす。
      final container = ProviderContainer(
        overrides: [overrideApiClient(mockApi)],
        retry: (retryCount, error) => null,
      );
      addTearDown(container.dispose);

      // Act & Assert
      await expectLater(
        container.read(daydudyProvider('group-1').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
