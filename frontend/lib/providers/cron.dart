import 'dart:async';

import 'package:nocsis/core/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cron.g.dart';

// Stream にしない。最初の値が届くまで読み込み中になり、watch している側が、値が届いたときにもう一度作られる
@riverpod
DateTime cron(Ref ref, String cronFormat) {
  final schedule = Cron.parse(cronFormat);
  final now = DateTime.now();

  final timer = Timer(schedule.next(now).difference(now), ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return now;
}
