import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events.g.dart';

@riverpod
Future<ApiV1GroupsGroupIdEventsGet$Response> events(
  Ref ref,
  String groupId,
) async {
  // 一日ごとに取得
  ref.watch(cronProvider("0 0 * * *"));

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  final to = DateTime(now.year, now.month, now.day + 30); // 1か月分取得

  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1GroupsGroupIdEventsGet(
    groupId: groupId,
    from: from,
    to: to,
  );

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Events fetch failed: ${response.statusCode}');
  }
}
