import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/weather.dart';

import '../helpers/mock_api_client.dart';

void main() {
  group('weatherProvider', () {
    late MockApi mockApi;

    setUp(() {
      mockApi = MockApi();
    });

    test('天気情報を取得できる', () async {
      // Arrange
      final weatherData = WeatherData(
        current: const WeatherData$Current(
          temp: 20.5,
          name: WeatherData$CurrentName.clear,
        ),
        hourly: const WeatherData$Hourly(temp: [20.0, 21.0], pop: [0.1, 0.2]),
        threeHour: const [WeatherDataThreeHour.clear],
      );
      when(
        () => mockApi.apiV1GroupsGroupIdWeatherNowGet(groupId: 'group-1'),
      ).thenAnswer(
        (_) async => chopper.Response(http.Response('', 200), weatherData),
      );

      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWith((ref) async => mockApi)],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(weatherProvider('group-1').future);

      // Assert
      expect(result, weatherData);
    });

    test('APIが失敗を返した場合は例外を投げる', () async {
      // Arrange
      when(
        () => mockApi.apiV1GroupsGroupIdWeatherNowGet(groupId: 'group-1'),
      ).thenAnswer(
        (_) async =>
            chopper.Response<WeatherData>(http.Response('', 500), null),
      );

      // Riverpod 3.x はデフォルトで失敗時にリトライするため、
      // リトライを無効化して即座に AsyncError へ落とす。
      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWith((ref) async => mockApi)],
        retry: (retryCount, error) => null,
      );
      addTearDown(container.dispose);

      // Act & Assert
      await expectLater(
        container.read(weatherProvider('group-1').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
