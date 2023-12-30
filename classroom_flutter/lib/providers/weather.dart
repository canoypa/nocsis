import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather.g.dart';

final fn = FirebaseFunctions.instance.httpsCallable("v2-weather-now");

@riverpod
Future<dynamic> weather(_) async {
  final res = await fn.call();
  return res.data;
}
