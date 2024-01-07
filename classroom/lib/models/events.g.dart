// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventListImpl _$$EventListImplFromJson(Map<String, dynamic> json) =>
    _$EventListImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EventListImplToJson(_$EventListImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

_$EventDataImpl _$$EventDataImplFromJson(Map<String, dynamic> json) =>
    _$EventDataImpl(
      title: json['title'] as String,
      isAllDay: json['isAllDay'] as bool,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
    );

Map<String, dynamic> _$$EventDataImplToJson(_$EventDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'isAllDay': instance.isAllDay,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt.toIso8601String(),
    };
