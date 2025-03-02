import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis/converters/local_date_time.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@freezed
class EventList with _$EventList {
  const factory EventList({required List<EventData> items}) = _EventList;

  factory EventList.fromJson(Map<String, dynamic> json) =>
      _$EventListFromJson(json);
}

@freezed
class EventData with _$EventData {
  const factory EventData({
    required String title,
    required bool isAllDay,
    @LocalDateTimeConverter() required DateTime startAt,
    @LocalDateTimeConverter() required DateTime endAt,
  }) = _EventData;

  factory EventData.fromJson(Map<String, dynamic> json) =>
      _$EventDataFromJson(json);
}
