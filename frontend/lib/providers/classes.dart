import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/classes.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-classes-get");

@riverpod
Future<ClassList> classes(Ref ref, String groupId) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final now = DateTime.now();

  // 新しいAPIの呼び出しテスト
  try {
    final client = await ref.read(apiClientProvider.future);
    final newApiFrom = DateTime(now.year, now.month, now.day);
    final newApiTo = DateTime(now.year, now.month, now.day + 1);

    unawaited(
      client
          .apiV1GroupsGroupIdClassesGet(
            groupId: groupId,
            from: newApiFrom,
            to: newApiTo,
          )
          .then((_) {})
          .catchError((error) {
            // ignore: avoid_print
            print('[Classes] New API test error: $error');
          }),
    );
  } catch (error) {
    // ignore: avoid_print
    print('[Classes] New API client initialization failed');
  }

  final from = DateTime(now.year, now.month, now.day).toIso8601String();
  final to = DateTime(now.year, now.month, now.day + 1).toIso8601String();

  final res = await fn.call({'groupId': groupId, "from": from, "to": to});

  if (res.data == null) {
    throw Exception("No data");
  }

  return ClassList.fromJson(res.data);
}
