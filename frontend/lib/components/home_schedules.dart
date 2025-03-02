import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/providers/classes.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:nocsis/providers/events.dart';

class HomeSchedules extends ConsumerWidget {
  const HomeSchedules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 毎分更新
    ref.watch(CronProvider("* * * * *"));

    final classes = ref
        .watch(classesProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);
    final events = ref
        .watch(eventsProvider)
        .maybeWhen(data: (data) => data, orElse: () => null);

    if (classes != null && classes.items.isNotEmpty) {
      final upcomingClasses = classes.items.where(
        (e) => e.endAt.isAfter(DateTime.now()),
      );

      if (upcomingClasses.isNotEmpty) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "今日の授業",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                ...upcomingClasses.map((e) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        "${e.period}時限目",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }
    }

    if (events != null && events.items.isNotEmpty) {
      final eventDateFormatter = DateFormat('M月dd日');
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "今後のイベント",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              ...events.items.map((e) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      // utc なので表示用にローカルに変換
                      eventDateFormatter.format(e.startAt.toLocal()),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
