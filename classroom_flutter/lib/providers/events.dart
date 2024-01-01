import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/daydudy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-events-get");

@riverpod
Stream<Daydudy> events(_) async* {
  // 一日ごとに取得
  final schedule = Cron.parse("0 0 * * *");

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  const limit = 3;

  while (true) {
    final res = await fn.call({"from": from, "limit": limit});
    yield Daydudy.fromJson(res.data);

    final now = DateTime.now();
    await Future.delayed(schedule.next(now).difference(now));
  }
}
