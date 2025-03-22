import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/events.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-events-get");

@riverpod
Future<EventList> events(Ref ref, String groupId) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day).toIso8601String();
  const limit = 3;

  final res = await fn.call({'groupId': groupId, "from": from, "limit": limit});

  if (res.data == null) {
    throw Exception("No data");
  }

  return EventList.fromJson(res.data);
}
