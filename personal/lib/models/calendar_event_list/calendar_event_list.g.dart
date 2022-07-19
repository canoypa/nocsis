// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CalendarEventList _$$_CalendarEventListFromJson(Map<String, dynamic> json) =>
    _$_CalendarEventList(
      isEmpty: json['isEmpty'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_CalendarEventListToJson(
        _$_CalendarEventList instance) =>
    <String, dynamic>{
      'isEmpty': instance.isEmpty,
      'items': instance.items,
    };
