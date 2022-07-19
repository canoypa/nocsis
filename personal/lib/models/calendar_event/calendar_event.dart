import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_personal/models/datetime_converter.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String title,
    required bool isAllDay,
    @DateTimeConverter() required DateTime startAt,
    @DateTimeConverter() required DateTime endAt,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}
