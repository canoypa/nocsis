// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyEventListImpl _$$MonthlyEventListImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyEventListImpl(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => MonthEventList.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$MonthlyEventListImplToJson(
  _$MonthlyEventListImpl instance,
) => <String, dynamic>{'items': instance.items};

_$MonthEventListImpl _$$MonthEventListImplFromJson(Map<String, dynamic> json) =>
    _$MonthEventListImpl(
      month: json['month'] as String,
      items:
          (json['items'] as List<dynamic>)
              .map((e) => EventData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$MonthEventListImplToJson(
  _$MonthEventListImpl instance,
) => <String, dynamic>{'month': instance.month, 'items': instance.items};
