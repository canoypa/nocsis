import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/components/during_class_progress.dart';
import 'package:nocsis_classroom/models/classes.dart';
import 'package:nocsis_classroom/providers/cron.dart';

class DuringClassScreen extends ConsumerWidget {
  final ClassData? data;

  const DuringClassScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 毎分更新
    ref.watch(cronProvider("* * * * *"));

    final classData = data;

    if (classData == null) {
      return const SizedBox();
    }

    //残り時間を分で計算
    final classTerm = classData.endAt.difference(classData.startAt);
    final remainingTime = classTerm.inMinutes -
        DateTime.now().difference(classData.startAt).inMinutes;

    return Stack(
      children: [
        DuringClassProgress(data: classData),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${classData.period}時間目",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Text("・"),
                  Text(
                    classData.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              Text(
                "$remainingTime分",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
