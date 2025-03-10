// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventList _$EventListFromJson(Map<String, dynamic> json) => _EventList(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$EventListToJson(_EventList instance) =>
    <String, dynamic>{'items': instance.items};

_EventData _$EventDataFromJson(Map<String, dynamic> json) => _EventData(
  title: json['title'] as String,
  isAllDay: json['isAllDay'] as bool,
  startAt: const LocalDateTimeConverter().fromJson(json['startAt'] as String),
  endAt: const LocalDateTimeConverter().fromJson(json['endAt'] as String),
);

Map<String, dynamic> _$EventDataToJson(_EventData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'isAllDay': instance.isAllDay,
      'startAt': const LocalDateTimeConverter().toJson(instance.startAt),
      'endAt': const LocalDateTimeConverter().toJson(instance.endAt),
    };
