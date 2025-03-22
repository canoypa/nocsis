// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthlyEventList _$MonthlyEventListFromJson(Map<String, dynamic> json) =>
    _MonthlyEventList(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => MonthEventList.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MonthlyEventListToJson(_MonthlyEventList instance) =>
    <String, dynamic>{'items': instance.items};

_MonthEventList _$MonthEventListFromJson(Map<String, dynamic> json) =>
    _MonthEventList(
      month: json['month'] as String,
      items:
          (json['items'] as List<dynamic>)
              .map((e) => EventData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MonthEventListToJson(_MonthEventList instance) =>
    <String, dynamic>{'month': instance.month, 'items': instance.items};
