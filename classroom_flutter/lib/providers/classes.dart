import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/classes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-classes-get");

@riverpod
Stream<ClassList> classes(_) async* {
  // 一日ごとに取得
  final schedule = Cron.parse("0 0 * * *");

  while (true) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day).toIso8601String();
    final to = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    final res = await fn.call({"from": from, "to": to});
    yield ClassList.fromJson(res.data);

    await Future.delayed(schedule.next(now).difference(now));
  }
}
