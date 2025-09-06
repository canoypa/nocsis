import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/weather.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-weather-now");

@riverpod
Future<Weather> weather(Ref ref, String groupId) async {
  // 15分ごとに更新
  ref.watch(cronProvider("*/15 * * * *"));

  // 新しいAPIの呼び出しテスト
  try {
    final client = await ref.read(apiClientProvider.future);
    unawaited(
      client
          .apiV1GroupsGroupIdWeatherNowGet(groupId: groupId)
          .then((_) {})
          .catchError((error) {
            // ignore: avoid_print
            print('[Weather] New API test error: $error');
          }),
    );
  } catch (error) {
    // ignore: avoid_print
    print('[Weather] New API client initialization failed');
  }

  final res = await fn.call({'groupId': groupId});

  if (res.data == null) {
    throw Exception("No data");
  }

  return Weather.fromJson(res.data);
}
