import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/classes.dart';
import 'package:nocsis/providers/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'during_class_data.g.dart';

@riverpod
Future<Class?> duringClassData(Ref ref, String groupId) async {
  // 毎分更新
  ref.watch(cronProvider("* * * * *"));

  final classes = ref
      .watch(classesProvider(groupId))
      .maybeWhen(data: (data) => data, orElse: () => null);

  final now = DateTime.now();

  if (classes == null || classes.items.isEmpty) {
    return null;
  }

  final currentClass = classes.items.firstWhereOrNull(
    (e) => e.startAt.isBefore(now) && e.endAt.isAfter(now),
  );

  return currentClass;
}
