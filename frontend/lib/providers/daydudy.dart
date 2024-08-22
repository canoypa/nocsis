import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis/models/daydudy.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daydudy.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallableFromUri(
        Uri.parse("https://v3-dayduty-get-6joklbidfa-an.a.run.app"));

@riverpod
Future<Daydudy> daydudy(DaydudyRef ref) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final res = await fn.call({"date": DateTime.now().toIso8601String()});
  return Daydudy.fromJson(res.data);
}
