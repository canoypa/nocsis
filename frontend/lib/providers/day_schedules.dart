import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_schedules.g.dart';

class DaySchedules {
  final ApiV1GroupsGroupIdClassesGet$Response classes;
  final ApiV1GroupsGroupIdEventsGet$Response events;

  DaySchedules({required this.classes, required this.events});
}

@riverpod
Future<DaySchedules> daySchedules(Ref ref, String groupId, int epochDay) async {
  final date = DateTime.fromMillisecondsSinceEpoch(
    epochDay * Duration.millisecondsPerDay - Duration.millisecondsPerHour * 9,
  );

  final from = date;
  final to = date.add(const Duration(days: 1));

  final client = await ref.read(apiClientProvider.future);

  final result = await Future.wait([
    client.apiV1GroupsGroupIdClassesGet(groupId: groupId, from: from, to: to),
    client.apiV1GroupsGroupIdEventsGet(groupId: groupId, from: from, to: to),
  ]);

  if (!result[0].isSuccessful || result[0].body == null) {
    throw Exception('Classes fetch failed: ${result[0].statusCode}');
  }
  if (!result[1].isSuccessful || result[1].body == null) {
    throw Exception('Events fetch failed: ${result[1].statusCode}');
  }

  final newData = DaySchedules(
    classes: result[0].body! as ApiV1GroupsGroupIdClassesGet$Response,
    events: result[1].body! as ApiV1GroupsGroupIdEventsGet$Response,
  );

  return newData;
}
