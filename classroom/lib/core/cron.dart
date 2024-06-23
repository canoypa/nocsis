// from: https://github.com/agilord/cron

class Cron {
  final List<int>? minutes;
  final List<int>? hours;
  final List<int>? days;
  final List<int>? months;
  final List<int>? weekdays;

  Cron({this.minutes, this.hours, this.days, this.months, this.weekdays});

  factory Cron.parse(String cronFormat) {
    final p =
        cronFormat.split(RegExp('\\s+')).where((p) => p.isNotEmpty).toList();
    assert(p.length == 5 || p.length == 6);
    final parts = [
      if (p.length == 5) null,
      ...p,
    ];
    return Cron(
      minutes: _parseExpression(parts[1])?.toList(),
      hours: _parseExpression(parts[2])?.toList(),
      days: _parseExpression(parts[3])?.toList(),
      months: _parseExpression(parts[4])?.toList(),
      weekdays: _parseExpression(parts[5])?.toList(),
    );
  }

  DateTime next(DateTime now) {
    DateTime w = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );

    while (true) {
      if (months != null && !months!.contains(w.month)) {
        w = DateTime(w.year, w.month + 1);
        continue;
      }
      if (weekdays != null && !weekdays!.contains(w.weekday)) {
        //
        w = DateTime(w.year, w.month, w.day + 1);
        continue;
      }
      if (days != null && !days!.contains(w.day)) {
        w = DateTime(w.year, w.month, w.day + 1);
        continue;
      }
      if (hours != null && !hours!.contains(w.hour)) {
        w = DateTime(w.year, w.month, w.day, w.hour + 1);
        continue;
      }
      if (minutes != null && !minutes!.contains(w.minute)) {
        w = DateTime(w.year, w.month, w.day, w.hour, w.minute + 1);
        continue;
      }

      break;
    }

    return w;
  }

  static List<int>? _parseExpression(dynamic expression) {
    if (expression == null) return null;
    if (expression is int) return [expression];
    if (expression is List<int>) return expression;

    if (expression is String) {
      if (expression == '*' || expression == '') return null;

      final parts = expression.split(',');
      if (parts.length > 1) {
        final items = parts
            .map(_parseExpression)
            .expand((list) => list!)
            .toSet()
            .toList();
        items.sort();
        return items;
      }

      final singleValue = int.tryParse(expression);
      if (singleValue != null) return [singleValue];

      if (expression.startsWith('*/')) {
        final period = int.tryParse(expression.substring(2)) ?? -1;
        if (period > 0) {
          return List.generate(120 ~/ period, (i) => i * period);
        }
      }

      if (expression.contains('-')) {
        final ranges = expression.split('-');
        if (ranges.length == 2) {
          final lower = int.tryParse(ranges.first) ?? -1;
          final higher = int.tryParse(ranges.last) ?? -1;
          if (lower <= higher) {
            return List.generate(higher - lower + 1, (i) => i + lower);
          }
        }
      }
    }

    throw ScheduleParseException('Unable to parse: $expression');
  }
}

class ScheduleParseException extends FormatException {
  ScheduleParseException([super.message]);
}
