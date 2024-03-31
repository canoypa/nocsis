// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthEventsImpl _$$MonthEventsImplFromJson(Map<String, dynamic> json) =>
    _$MonthEventsImpl(
      month: json['month'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MonthEventsImplToJson(_$MonthEventsImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'items': instance.items,
    };

_$MonthlyEventsImpl _$$MonthlyEventsImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyEventsImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => MonthEvents.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MonthlyEventsImplToJson(_$MonthlyEventsImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
