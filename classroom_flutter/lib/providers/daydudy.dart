import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/models/daydudy.dart';
import 'package:nocsis_classroom/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daydudy.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-dayduty-get");

@riverpod
Future<Daydudy> daydudy(DaydudyRef ref) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final res = await fn.call({"date": DateTime.now().toIso8601String()});
  return Daydudy.fromJson(res.data);
}
