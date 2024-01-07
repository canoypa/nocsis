import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@freezed
class EventList with _$EventList {
  const factory EventList({
    required List<EventData> items,
  }) = _EventList;

  factory EventList.fromJson(Map<String, dynamic> json) =>
      _$EventListFromJson(json);
}

@freezed
class EventData with _$EventData {
  const factory EventData({
    required String title,
    required bool isAllDay,
    required DateTime startAt,
    required DateTime endAt,
  }) = _EventData;

  factory EventData.fromJson(Map<String, dynamic> json) =>
      _$EventDataFromJson(json);
}
