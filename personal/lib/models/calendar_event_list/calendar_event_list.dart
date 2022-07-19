import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_personal/models/calendar_event/calendar_event.dart';

part 'calendar_event_list.freezed.dart';
part 'calendar_event_list.g.dart';

@freezed
abstract class CalendarEventList with _$CalendarEventList {
  const factory CalendarEventList({
    required bool isEmpty,
    required List<CalendarEvent> items,
  }) = _CalendarEventList;

  factory CalendarEventList.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventListFromJson(json);
}
