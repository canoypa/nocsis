// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassList _$ClassListFromJson(Map<String, dynamic> json) => _ClassList(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => ClassData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ClassListToJson(_ClassList instance) =>
    <String, dynamic>{'items': instance.items};

_ClassData _$ClassDataFromJson(Map<String, dynamic> json) => _ClassData(
  title: json['title'] as String,
  period: (json['period'] as num).toInt(),
  startAt: const LocalDateTimeConverter().fromJson(json['startAt'] as String),
  endAt: const LocalDateTimeConverter().fromJson(json['endAt'] as String),
);

Map<String, dynamic> _$ClassDataToJson(_ClassData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'startAt': const LocalDateTimeConverter().toJson(instance.startAt),
      'endAt': const LocalDateTimeConverter().toJson(instance.endAt),
    };
