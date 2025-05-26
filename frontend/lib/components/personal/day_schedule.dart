import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/components/personal/class_list.dart';
import 'package:nocsis/components/personal/event_list.dart';
import 'package:nocsis/providers/day_schedules.dart';
import 'package:nocsis/providers/current_group_id.dart';

class DaySchedule extends ConsumerWidget {
  final int epochDay;

  const DaySchedule({super.key, required this.epochDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final snapshot = ref.watch(daySchedulesProvider(groupId, epochDay));

    return snapshot.when(
      data: (data) {
        if (data.classes.items.isEmpty && data.events.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.event_available_outlined), Text("予定なし")],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.classes.items.isNotEmpty)
              ClassListView(items: data.classes.items),
            if (data.events.items.isNotEmpty)
              EventListView(items: data.events.items),
          ],
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stackTrace) {
        return const Center(child: Text('Something went wrong'));
      },
    );
  }
}
