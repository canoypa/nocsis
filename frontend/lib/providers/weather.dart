import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

@riverpod
Future<WeatherData> weather(Ref ref, String groupId) async {
  // 15分ごとに更新
  ref.watch(cronProvider("*/15 * * * *"));

  final client = await ref.read(apiClientProvider.future);

  final response = await client.apiV1GroupsGroupIdWeatherNowGet(
    groupId: groupId,
  );

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Weather data fetch failed: ${response.statusCode}');
  }
}
