import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daydudy.g.dart';

@riverpod
Future<Classmate> daydudy(Ref ref, String groupId) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1GroupsGroupIdDaydutyGet(
    groupId: groupId,
    date: DateTime.now(),
  );

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Dayduty fetch failed: ${response.statusCode}');
  }
}
