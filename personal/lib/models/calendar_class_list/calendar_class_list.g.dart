// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_class_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CalendarClassList _$$_CalendarClassListFromJson(Map<String, dynamic> json) =>
    _$_CalendarClassList(
      isEmpty: json['isEmpty'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => CalendarClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_CalendarClassListToJson(
        _$_CalendarClassList instance) =>
    <String, dynamic>{
      'isEmpty': instance.isEmpty,
      'items': instance.items,
    };
