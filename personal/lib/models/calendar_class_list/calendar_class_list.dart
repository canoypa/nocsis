import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_personal/models/calendar_class/calendar_class.dart';

part 'calendar_class_list.freezed.dart';
part 'calendar_class_list.g.dart';

@freezed
abstract class CalendarClassList with _$CalendarClassList {
  const factory CalendarClassList({
    required bool isEmpty,
    required List<CalendarClass> items,
  }) = _CalendarClassList;

  factory CalendarClassList.fromJson(Map<String, dynamic> json) =>
      _$CalendarClassListFromJson(json);
}
