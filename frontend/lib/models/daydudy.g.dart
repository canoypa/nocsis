// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daydudy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DaydudyImpl _$$DaydudyImplFromJson(Map<String, dynamic> json) =>
    _$DaydudyImpl(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      stuNo: (json['stuNo'] as num).toInt(),
    );

Map<String, dynamic> _$$DaydudyImplToJson(_$DaydudyImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'stuNo': instance.stuNo,
    };
