import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/models/weather.dart';
import 'package:nocsis_classroom/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallableFromUri(
        Uri.parse("https://v3-weather-now-6joklbidfa-an.a.run.app"));

@riverpod
Future<Weather> weather(WeatherRef ref) async {
  // 15分ごとに更新
  ref.watch(cronProvider("*/15 * * * *"));

  final res = await fn.call();
  return Weather.fromJson(res.data);
}
