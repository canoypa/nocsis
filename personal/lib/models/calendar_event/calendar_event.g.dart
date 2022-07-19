// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CalendarEvent _$$_CalendarEventFromJson(Map<String, dynamic> json) =>
    _$_CalendarEvent(
      title: json['title'] as String,
      isAllDay: json['isAllDay'] as bool,
      startAt: const DateTimeConverter().fromJson(json['startAt'] as String),
      endAt: const DateTimeConverter().fromJson(json['endAt'] as String),
    );

Map<String, dynamic> _$$_CalendarEventToJson(_$_CalendarEvent instance) =>
    <String, dynamic>{
      'title': instance.title,
      'isAllDay': instance.isAllDay,
      'startAt': const DateTimeConverter().toJson(instance.startAt),
      'endAt': const DateTimeConverter().toJson(instance.endAt),
    };
