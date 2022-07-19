import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_personal/models/datetime_converter.dart';

part 'calendar_class.freezed.dart';
part 'calendar_class.g.dart';

@freezed
abstract class CalendarClass with _$CalendarClass {
  const factory CalendarClass({
    required String title,
    required int period,
    @DateTimeConverter() required DateTime startAt,
    @DateTimeConverter() required DateTime endAt,
  }) = _CalendarClass;

  factory CalendarClass.fromJson(Map<String, dynamic> json) =>
      _$CalendarClassFromJson(json);
}
