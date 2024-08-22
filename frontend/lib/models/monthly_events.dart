import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis_classroom/models/events.dart';

part 'monthly_events.freezed.dart';
part 'monthly_events.g.dart';

@freezed
class MonthlyEventList with _$MonthlyEventList {
  const factory MonthlyEventList({
    required List<MonthEventList> items,
  }) = _MonthlyEventList;

  factory MonthlyEventList.fromJson(Map<String, dynamic> json) =>
      _$MonthlyEventListFromJson(json);
}

@freezed
class MonthEventList with _$MonthEventList {
  const factory MonthEventList({
    required String month,
    required List<EventData> items,
  }) = _MonthEventList;

  factory MonthEventList.fromJson(Map<String, dynamic> json) =>
      _$MonthEventListFromJson(json);
}