// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarClassImpl _$$CalendarClassImplFromJson(Map<String, dynamic> json) =>
    _$CalendarClassImpl(
      title: json['title'] as String,
      period: json['period'] as int,
      startAt: const DateTimeConverter().fromJson(json['startAt'] as String),
      endAt: const DateTimeConverter().fromJson(json['endAt'] as String),
    );

Map<String, dynamic> _$$CalendarClassImplToJson(_$CalendarClassImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'startAt': const DateTimeConverter().toJson(instance.startAt),
      'endAt': const DateTimeConverter().toJson(instance.endAt),
    };
