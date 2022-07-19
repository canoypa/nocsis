import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_personal/models/calendar_event/calendar_event.dart';

part 'monthly_events.freezed.dart';
part 'monthly_events.g.dart';

@freezed
abstract class MonthEvents with _$MonthEvents {
  const factory MonthEvents({
    required String month,
    required List<CalendarEvent> items,
  }) = _MonthEvents;

  factory MonthEvents.fromJson(Map<String, dynamic> json) =>
      _$MonthEventsFromJson(json);
}

@freezed
abstract class MonthlyEvents with _$MonthlyEvents {
  const factory MonthlyEvents({
    required List<MonthEvents> items,
  }) = _MonthlyEvents;

  factory MonthlyEvents.fromJson(Map<String, dynamic> json) =>
      _$MonthlyEventsFromJson(json);
}
