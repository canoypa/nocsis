import 'package:collection/collection.dart';
import 'package:nocsis_classroom/core/cron.dart';
import 'package:nocsis_classroom/models/classes.dart';
import 'package:nocsis_classroom/providers/classes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'during_class_data.g.dart';

@riverpod
Stream<ClassData?> duringClassData(DuringClassDataRef ref) async* {
  final schedule = Cron.parse("* * * * *");

  final classes = ref.watch(classesProvider).whenOrNull(data: (data) => data);

  while (true) {
    final now = DateTime.now();

    if (classes == null || classes.items.isEmpty) {
      yield null;
    } else {
      final currentClass = classes.items.firstWhereOrNull(
        (e) => e.startAt.isBefore(now) && e.endAt.isAfter(now),
      );

      yield currentClass;
    }

    await Future.delayed(schedule.next(now).difference(now));
  }
}
