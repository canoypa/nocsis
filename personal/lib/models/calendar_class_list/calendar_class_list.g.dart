// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_class_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarClassListImpl _$$CalendarClassListImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarClassListImpl(
      isEmpty: json['isEmpty'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CalendarClassListImplToJson(
        _$CalendarClassListImpl instance) =>
    <String, dynamic>{
      'isEmpty': instance.isEmpty,
      'items': instance.items,
    };
