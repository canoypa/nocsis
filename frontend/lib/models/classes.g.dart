// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassListImpl _$$ClassListImplFromJson(Map<String, dynamic> json) =>
    _$ClassListImpl(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => ClassData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$ClassListImplToJson(_$ClassListImpl instance) =>
    <String, dynamic>{'items': instance.items};

_$ClassDataImpl _$$ClassDataImplFromJson(Map<String, dynamic> json) =>
    _$ClassDataImpl(
      title: json['title'] as String,
      period: (json['period'] as num).toInt(),
      startAt: const LocalDateTimeConverter().fromJson(
        json['startAt'] as String,
      ),
      endAt: const LocalDateTimeConverter().fromJson(json['endAt'] as String),
    );

Map<String, dynamic> _$$ClassDataImplToJson(_$ClassDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'startAt': const LocalDateTimeConverter().toJson(instance.startAt),
      'endAt': const LocalDateTimeConverter().toJson(instance.endAt),
    };
