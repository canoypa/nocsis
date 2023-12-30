import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/models/weather.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-weather-now");

@riverpod
Future<Weather> weather(_) async {
  final res = await fn.call();
  return Weather.fromJson(res.data);
}
