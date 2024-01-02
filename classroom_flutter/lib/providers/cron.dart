import 'package:nocsis_classroom/core/cron.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cron.g.dart';

@riverpod
Stream<DateTime> cron(_, String cronFormat) async* {
  final schedule = Cron.parse(cronFormat);

  while (true) {
    final now = DateTime.now();
    yield now;
    await Future.delayed(schedule.next(now).difference(now));
  }
}
