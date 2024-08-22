import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/core/cron.dart';

void main() {
  group('Cron', () {
    test('next() should return the next valid DateTime', () {
      final cron = Cron.parse('*/15 5-10 13 2,4,6 4');

      expect(
        cron.next(DateTime(2023, 2, 3, 4, 5)),
        DateTime(2023, 4, 13, 5, 0),
      );
      expect(
        cron.next(DateTime(2023, 4, 13, 5, 0)),
        DateTime(2023, 4, 13, 5, 15),
      );
    });

    test('parse() should create a Cron instance from cron-formatted text', () {
      const cronFormat = '*/15 5-10 2,4,8,16 10 *';
      final cron = Cron.parse(cronFormat);

      expect(cron.minutes, [0, 15, 30, 45]);
      expect(cron.hours, [5, 6, 7, 8, 9, 10]);
      expect(cron.days, [2, 4, 8, 16]);
      expect(cron.months, [10]);
      expect(cron.weekdays, null);
    });
  });
}
