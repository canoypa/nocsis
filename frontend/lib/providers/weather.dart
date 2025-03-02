import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/weather.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v3-weather-now");

@riverpod
Future<Weather> weather(Ref ref) async {
  // 15分ごとに更新
  ref.watch(cronProvider("*/15 * * * *"));

  final res = await fn.call();

  if (res.data == null) {
    throw Exception("No data");
  }

  return Weather.fromJson(res.data);
}
