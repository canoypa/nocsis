import 'dart:async';

import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/components/weather_info.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/weather.dart';

import '../helpers/mock_api_client.dart';

void main() {
  testWidgets('読み込めなかった後の 15 分ごとの読み直し中は、スケルトンを出さない', (tester) async {
    final mockApi = MockApi();
    final reloaded = Completer<chopper.Response<WeatherData>>();
    var failing = true;
    when(() => mockApi.apiV1GroupsGroupIdWeatherNowGet(groupId: 'g1'))
        .thenAnswer((_) {
          return failing
              ? Future.value(chopper.Response(http.Response('', 500), null))
              : reloaded.future;
        });
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith((ref) async => mockApi),
        cronProvider('*/15 * * * *').overrideWith((ref) => DateTime.now()),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ProviderScope(
          overrides: [currentGroupIdProvider.overrideWithValue('g1')],
          child: MaterialApp(
            home: ScreenUtilInit(
              builder: (_, _) => const Scaffold(body: WeatherInfo()),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(weatherProvider('g1')).hasError, isTrue);

    failing = false;
    container.invalidate(cronProvider('*/15 * * * *'));
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('読み込み中'), findsNothing);

    reloaded.complete(chopper.Response(http.Response('', 500), null));
    await tester.pump();
  });
}
