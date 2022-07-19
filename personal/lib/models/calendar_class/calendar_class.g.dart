// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CalendarClass _$$_CalendarClassFromJson(Map<String, dynamic> json) =>
    _$_CalendarClass(
      title: json['title'] as String,
      period: json['period'] as int,
      startAt: const DateTimeConverter().fromJson(json['startAt'] as String),
      endAt: const DateTimeConverter().fromJson(json['endAt'] as String),
    );

Map<String, dynamic> _$$_CalendarClassToJson(_$_CalendarClass instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'startAt': const DateTimeConverter().toJson(instance.startAt),
      'endAt': const DateTimeConverter().toJson(instance.endAt),
    };
