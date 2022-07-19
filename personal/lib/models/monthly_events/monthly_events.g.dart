// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MonthEvents _$$_MonthEventsFromJson(Map<String, dynamic> json) =>
    _$_MonthEvents(
      month: json['month'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_MonthEventsToJson(_$_MonthEvents instance) =>
    <String, dynamic>{
      'month': instance.month,
      'items': instance.items,
    };

_$_MonthlyEvents _$$_MonthlyEventsFromJson(Map<String, dynamic> json) =>
    _$_MonthlyEvents(
      items: (json['items'] as List<dynamic>)
          .map((e) => MonthEvents.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_MonthlyEventsToJson(_$_MonthlyEvents instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
