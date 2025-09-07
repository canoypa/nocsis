import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/basic_card.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/current_group_id.dart';

// 月毎のイベントグループ
class MonthEventGroup {
  final String month;
  final List<Event> items;

  MonthEventGroup({required this.month, required this.items});
}

final eventsProvider = FutureProvider.family<List<MonthEventGroup>, String>((
  ref,
  groupId,
) async {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  final client = await ref.read(apiClientProvider.future);

  final response = await client.apiV1GroupsGroupIdEventsGet(
    groupId: groupId,
    from: today,
    limit: 3,
  );

  if (response.isSuccessful && response.body != null) {
    final events = response.body!.items;

    // 月毎にグループ化
    final monthGroups = groupBy(events, (Event event) {
      final DateTime? startDate = DateTime.tryParse(event.startAt as String);
      return DateFormat('yyyy-MM').format(startDate!);
    });

    // MonthEventGroupのリストに変換
    final result = monthGroups.entries.map((entry) {
      final date = DateTime.parse('${entry.key}-01');
      final monthName = DateFormat('yyyy-MM').format(date);
      return MonthEventGroup(month: monthName, items: entry.value);
    }).toList();

    // 日付順にソート
    result.sort((a, b) => a.month.compareTo(b.month));

    return result;
  } else {
    throw Exception('Events fetch failed: ${response.statusCode}');
  }
});

class EventsView extends ConsumerWidget {
  const EventsView({super.key});

  @override
  Widget build(context, ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final snap = ref.watch(eventsProvider(groupId));

    return snap.when(
      data: (monthGroups) {
        if (monthGroups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.event_available_outlined), Text("予定なし")],
            ),
          );
        }

        return ListView.builder(
          controller: ScrollController(),
          itemCount: monthGroups.length,
          itemBuilder: (c, i) {
            final monthGroup = monthGroups[i];
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    ListTile(title: Text("${monthGroup.month.split('-')[1]}月")),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: monthGroup.items.map((event) {
                          final DateTime? startDate = DateTime.tryParse(
                            event.startAt as String,
                          );

                          return BasicCard(
                            primary: Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            // TODO: 日を跨いだりする場合の表示に対応する
                            secondary: Text(
                              DateFormat("M月d日").format(startDate!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (error, stackTrace) {
        return const Center(child: Text('Something went wrong'));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
