import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/user_joined_groups.dart';

import '../helpers/mock_api_client.dart';

void main() {
  group('userJoinedGroupsProvider', () {
    late MockApi mockApi;

    setUp(() {
      mockApi = MockApi();
    });

    test('参加しているグループ一覧を取得できる', () async {
      // Arrange
      final group = Group(
        id: 'group-1',
        name: 'テストグループ',
        classesCalendarId: 'classes-cal',
        eventsCalendarId: 'events-cal',
        daydutyStartDate: '2024-01-01',
        slackEventChannelId: 'C123',
        weatherPoint: const WeatherPoint(lat: 35.0, lon: 139.0),
      );
      when(() => mockApi.apiV1UsersMeGroupsGet()).thenAnswer(
        (_) async => chopper.Response(
          http.Response('', 200),
          UserJoinedGroups(items: [group]),
        ),
      );

      final container = ProviderContainer(
        overrides: [overrideApiClient(mockApi)],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(userJoinedGroupsProvider.future);

      // Assert
      expect(result.items, [group]);
    });

    test('APIが失敗を返した場合は例外を投げる', () async {
      // Arrange
      when(() => mockApi.apiV1UsersMeGroupsGet()).thenAnswer(
        (_) async =>
            chopper.Response<UserJoinedGroups>(http.Response('', 500), null),
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
        container.read(userJoinedGroupsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
