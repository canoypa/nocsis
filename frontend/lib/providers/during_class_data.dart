import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/classes.dart';
import 'package:nocsis/providers/classes.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'during_class_data.g.dart';

@riverpod
Future<ClassData?> duringClassData(Ref ref) async {
  // 毎分更新
  ref.watch(cronProvider("* * * * *"));

  final classes = ref.watch(classesProvider).value;

  final now = DateTime.now();

  if (classes == null || classes.items.isEmpty) {
    return null;
  }

  final currentClass = classes.items.firstWhereOrNull(
    (e) => e.startAt.isBefore(now) && e.endAt.isAfter(now),
  );

  return currentClass;
}
