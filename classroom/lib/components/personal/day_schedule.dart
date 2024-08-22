import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/components/personal/class_list.dart';
import 'package:nocsis_classroom/components/personal/event_list.dart';
import 'package:nocsis_classroom/models/classes.dart';
import 'package:nocsis_classroom/models/events.dart';

class DaySchedules {
  final ClassList classes;
  final EventList events;

  DaySchedules({
    required this.classes,
    required this.events,
  });
}

class DaySchedulesState extends StateNotifier<Map<int, DaySchedules>> {
  DaySchedulesState() : super(<int, DaySchedules>{});

  Future<DaySchedules> get(int epochDay) async {
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochDay * Duration.millisecondsPerDay - Duration.millisecondsPerHour * 9,
    );

    if (state.containsKey(epochDay)) {
      return Future.value(state[epochDay]);
    }

    final from = date.toIso8601String();
    final to = date.add(const Duration(days: 1)).toIso8601String();

    final result = await Future.wait([
      _getClasses(from, to),
      _getEvents(from, to),
    ]);

    final newData = DaySchedules(
      classes: ClassList.fromJson(result[0]),
      events: EventList.fromJson(result[1]),
    );

    state = {
      ...state,
      epochDay: newData,
    };

    return newData;
  }

  // 授業を取得
  Future<dynamic> _getClasses(String from, String to) async {
    final HttpsCallable getClasses =
        FirebaseFunctions.instanceFor(region: "asia-northeast1")
            .httpsCallableFromUri(
                Uri.parse("https://v3-classes-get-6joklbidfa-an.a.run.app"));

    final res = await getClasses.call({"from": from, "to": to});

    return res.data;
  }

  // イベントを取得
  Future<dynamic> _getEvents(String from, String to) async {
    final HttpsCallable getClasses =
        FirebaseFunctions.instanceFor(region: "asia-northeast1")
            .httpsCallableFromUri(
                Uri.parse("https://v3-events-get-6joklbidfa-an.a.run.app"));

    final res = await getClasses.call({"from": from, "to": to});

    return res.data;
  }
}

final daySchedulesProvider =
    StateNotifierProvider<DaySchedulesState, Map<int, dynamic>>((ref) {
  return DaySchedulesState();
});

class DaySchedule extends ConsumerWidget {
  final int epochDay;

  const DaySchedule({
    super.key,
    required this.epochDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(daySchedulesProvider.notifier).get(epochDay);

    return FutureBuilder<DaySchedules>(
      future: future,
      builder: (c, snap) {
        if (snap.hasData) {
          final data = snap.data!;
          if (data.classes.items.isEmpty && data.events.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available_outlined),
                  Text("予定なし"),
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!data.classes.items.isEmpty)
                ClassListView(items: data.classes.items),
              if (!data.events.items.isEmpty)
                EventListView(items: data.events.items),
            ],
          );
        }

        if (snap.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}