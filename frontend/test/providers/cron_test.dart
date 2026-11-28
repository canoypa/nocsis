import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/cron.dart';

void main() {
  test('毎分の書式なら、1分以内に新しい時刻に変わる', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final changes = <DateTime>[];
      container.listen(
        cronProvider('* * * * *'),
        (_, next) => changes.add(next),
      );

      async.elapse(const Duration(minutes: 1));

      expect(changes, isNotEmpty);
      container.dispose();
    });
  });

  test('読む人がいなくなったら、待っている時刻を残さない', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      final subscription = container.listen(
        cronProvider('0 0 * * *'),
        (_, _) {},
      );

      subscription.close();
      async.flushMicrotasks();
      async.elapse(Duration.zero);

      expect(async.pendingTimers, isEmpty);
      container.dispose();
    });
  });
}
