import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/basic_card.dart';
import 'package:nocsis/models/monthly_events.dart';

final eventsProvider = FutureProvider.family<MonthlyEventList, String>((
  ref,
  groupId,
) async {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  final HttpsCallable getEvents = FirebaseFunctions.instanceFor(
    region: "asia-northeast1",
  ).httpsCallable("v4-events-monthly");

  final res = await getEvents.call({
    'groupId': groupId,
    "date": today.toIso8601String(),
  });

  return MonthlyEventList.fromJson({"items": res.data});
});

class EventsView extends ConsumerWidget {
  const EventsView({super.key});

  @override
  Widget build(context, ref) {
    final groupId = GoRouter.of(context).state.pathParameters['groupId']!;
    final snap = ref.watch(eventsProvider(groupId));

    return snap.when(
      data: (d) {
        if (d.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.event_available_outlined), Text("予定なし")],
            ),
          );
        }

        return ListView.builder(
          controller: ScrollController(),
          itemCount: d.items.length,
          itemBuilder: (c, i) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    ListTile(title: Text("${d.items[i].month}月")),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children:
                            (d.items[i].items).map((data) {
                              return BasicCard(
                                primary: Text(
                                  data.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                // TODO: 日を跨いだりする場合の表示に対応する
                                secondary: Text(
                                  DateFormat("M月d日").format(data.startAt),
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
