import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis/models/classes.dart';
import 'package:nocsis/models/events.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_schedules.g.dart';

final HttpsCallable getClasses = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-classes-get");

final HttpsCallable getEvents = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-events-get");

class DaySchedules {
  final ClassList classes;
  final EventList events;

  DaySchedules({required this.classes, required this.events});
}

@riverpod
Future<DaySchedules> daySchedules(Ref ref, String groupId, int epochDay) async {
  final date = DateTime.fromMillisecondsSinceEpoch(
    epochDay * Duration.millisecondsPerDay - Duration.millisecondsPerHour * 9,
  );

  // 新しいAPIの呼び出しテスト
  try {
    final client = await ref.read(apiClientProvider.future);
    final newApiFromDate = DateTime.fromMillisecondsSinceEpoch(
      epochDay * Duration.millisecondsPerDay - Duration.millisecondsPerHour * 9,
    );
    final newApiToDate = newApiFromDate.add(const Duration(days: 1));

    unawaited(
      client
          .apiV1GroupsGroupIdClassesGet(
            groupId: groupId,
            from: newApiFromDate,
            to: newApiToDate,
          )
          .then((_) => print('[DaySchedules] New API classes test success'))
          .catchError(
            (error) =>
                print('[DaySchedules] New API classes test error: $error'),
          ),
    );

    unawaited(
      client
          .apiV1GroupsGroupIdEventsGet(
            groupId: groupId,
            from: newApiFromDate,
            to: newApiToDate,
          )
          .then((_) => print('[DaySchedules] New API events test success'))
          .catchError(
            (error) =>
                print('[DaySchedules] New API events test error: $error'),
          ),
    );
  } catch (e) {
    print('[DaySchedules] New API client initialization failed');
  }

  final from = date.toIso8601String();
  final to = date.add(const Duration(days: 1)).toIso8601String();

  final result = await Future.wait([
    getClasses.call({'groupId': groupId, "from": from, "to": to}),
    getEvents.call({'groupId': groupId, "from": from, "to": to}),
  ]);

  final newData = DaySchedules(
    classes: ClassList.fromJson(result[0].data),
    events: EventList.fromJson(result[1].data),
  );

  return newData;
}
