import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/models/events.dart';
import 'package:nocsis_classroom/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-events-get");

@riverpod
Future<EventList> events(EventsRef ref) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day).toIso8601String();
  const limit = 3;

  final res = await fn.call({"from": from, "limit": limit});
  return EventList.fromJson(res.data);
}
