import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/classes.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:nocsis/providers/daydudy.dart';
import 'package:nocsis/providers/events.dart';
import 'package:nocsis/providers/weather.dart';

typedef _Case = ({
  String name,
  String cron,
  String path,
  Object body,
  ProviderListenable<AsyncValue<Object?>> Function() provider,
});

final _cases = <_Case>[
  (
    name: '日直',
    cron: '0 0 * * *',
    path: '/api/v1/groups/g1/dayduty',
    body: const Dayduty(name: 'テスト太郎').toJson(),
    provider: () => daydudyProvider('g1'),
  ),
  (
    name: '授業',
    cron: '0 0 * * *',
    path: '/api/v1/groups/g1/classes',
    body: {'items': []},
    provider: () => classesProvider('g1'),
  ),
  (
    name: 'イベント',
    cron: '0 0 * * *',
    path: '/api/v1/groups/g1/events',
    body: {'items': []},
    provider: () => eventsProvider('g1'),
  ),
  (
    name: '天気',
    cron: '*/15 * * * *',
    path: '/api/v1/groups/g1/weather/now',
    body: const WeatherData(
      current: WeatherData$Current(
        temp: 20.5,
        name: WeatherData$CurrentName.clear,
      ),
      hourly: WeatherData$Hourly(temp: [20.0], pop: [0.1]),
      threeHour: [WeatherDataThreeHour.clear],
    ).toJson(),
    provider: () => weatherProvider('g1'),
  ),
];

void main() {
  for (final c in _cases) {
    group(c.name, () {
      late ProviderContainer container;
      var requests = 0;

      setUp(() {
        requests = 0;
        final api = Api.create(
          baseUrl: Uri.parse('http://backend.test'),
          httpClient: MockClient((request) async {
            if (request.url.path != c.path) return http.Response('', 404);
            requests++;
            return http.Response(
              jsonEncode(c.body),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        container = ProviderContainer(
          overrides: [apiClientProvider.overrideWith((ref) async => api)],
          retry: (_, _) => null,
        );
        container.listen(c.provider(), (_, _) {});
      });

      tearDown(() => container.dispose());

      Future<void> settle() =>
          Future<void>.delayed(const Duration(milliseconds: 10));

      test('開いたときは1回だけ読む', () async {
        await settle();

        expect(container.read(c.provider()).hasValue, isTrue);
        expect(requests, 1);
      });

      test('次の時刻が来たら読み直す', () async {
        await settle();
        container.invalidate(cronProvider(c.cron));
        await settle();

        expect(requests, 2);
      });
    });
  }
}
