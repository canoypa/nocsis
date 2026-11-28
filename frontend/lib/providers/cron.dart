import 'dart:async';

import 'package:nocsis/core/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cron.g.dart';

@riverpod
DateTime cron(Ref ref, String cronFormat) {
  final schedule = Cron.parse(cronFormat);
  final now = DateTime.now();

  final timer = Timer(schedule.next(now).difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return now;
}
