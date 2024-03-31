// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventListImpl _$$CalendarEventListImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarEventListImpl(
      isEmpty: json['isEmpty'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CalendarEventListImplToJson(
        _$CalendarEventListImpl instance) =>
    <String, dynamic>{
      'isEmpty': instance.isEmpty,
      'items': instance.items,
    };
