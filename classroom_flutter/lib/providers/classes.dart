import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/daydudy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-classes-get");

@riverpod
Stream<Daydudy> classes(_) async* {
  // 一日ごとに取得
  final schedule = Cron.parse("0 0 * * *");

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  final to = DateTime(now.year, now.month, now.day + 1);

  while (true) {
    final res = await fn.call({"from": from, "to": to});
    yield Daydudy.fromJson(res.data);

    final now = DateTime.now();
    await Future.delayed(schedule.next(now).difference(now));
  }
}
