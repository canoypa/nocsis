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

  final classesRequest = client.apiV1GroupsGroupIdClassesGet(
    groupId: groupId,
    from: from,
    to: to,
  );
  final eventsRequest = client.apiV1GroupsGroupIdEventsGet(
    groupId: groupId,
    from: from,
    to: to,
  );

  final (classesResponse, eventsResponse) = await (
    classesRequest,
    eventsRequest,
  ).wait;

  if (!classesResponse.isSuccessful || classesResponse.body == null) {
    throw Exception('Classes fetch failed: ${classesResponse.statusCode}');
  }
  if (!eventsResponse.isSuccessful || eventsResponse.body == null) {
    throw Exception('Events fetch failed: ${eventsResponse.statusCode}');
  }

  final newData = DaySchedules(
    classes: classesResponse.body!,
    events: eventsResponse.body!,
  );

  return newData;
}
