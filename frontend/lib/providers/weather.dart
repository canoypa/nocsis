import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis/models/weather.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v3-weather-now");

@riverpod
Future<Weather> weather(WeatherRef ref) async {
  // 15分ごとに更新
  ref.watch(cronProvider("*/15 * * * *"));

  final res = await fn.call();
  return Weather.fromJson(res.data);
}
