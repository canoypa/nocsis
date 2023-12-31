import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/weather.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-weather-now");

@riverpod
Stream<Weather> weather(_) async* {
  // 15分ごとに更新
  final schedule = Cron.parse("*/15 * * * *");

  while (true) {
    final res = await fn.call();
    yield Weather.fromJson(res.data);

    final now = DateTime.now();
    await Future.delayed(schedule.next(now).difference(now));
  }
}
