import 'package:cloud_functions/cloud_functions.dart';
import 'package:nocsis_classroom/models/classes.dart';
import 'package:nocsis_classroom/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes.g.dart';

final fn = FirebaseFunctions.instanceFor(region: "asia-northeast1")
    .httpsCallable("v2-classes-get");

@riverpod
Future<ClassList> classes(ClassesRef ref) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day).toIso8601String();
  final to = DateTime(now.year, now.month, now.day + 1).toIso8601String();

  final res = await fn.call({"from": from, "to": to});
  return ClassList.fromJson(res.data);
}
