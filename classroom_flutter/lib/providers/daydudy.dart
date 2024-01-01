import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/daydudy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daydudy.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-dayduty-get");

@riverpod
Stream<Daydudy> daydudy(_) async* {
  // 一日ごとに取得
  final schedule = Cron.parse("0 0 * * *");

  while (true) {
    final res = await fn.call({"date": DateTime.now().toIso8601String()});
    yield Daydudy.fromJson(res.data);

    final now = DateTime.now();
    await Future.delayed(schedule.next(now).difference(now));
  }
}
