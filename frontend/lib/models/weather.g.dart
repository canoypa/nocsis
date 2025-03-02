// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherImpl _$$WeatherImplFromJson(Map<String, dynamic> json) =>
    _$WeatherImpl(
      current: WeatherCurrent.fromJson(json['current'] as Map<String, dynamic>),
      hourly: WeatherHourly.fromJson(json['hourly'] as Map<String, dynamic>),
      threeHour:
          (json['threeHour'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$WeatherImplToJson(_$WeatherImpl instance) =>
    <String, dynamic>{
      'current': instance.current,
      'hourly': instance.hourly,
      'threeHour': instance.threeHour,
    };

_$WeatherCurrentImpl _$$WeatherCurrentImplFromJson(Map<String, dynamic> json) =>
    _$WeatherCurrentImpl(
      name: json['name'] as String,
      temp: (json['temp'] as num).toInt(),
    );

Map<String, dynamic> _$$WeatherCurrentImplToJson(
  _$WeatherCurrentImpl instance,
) => <String, dynamic>{'name': instance.name, 'temp': instance.temp};

_$WeatherHourlyImpl _$$WeatherHourlyImplFromJson(Map<String, dynamic> json) =>
    _$WeatherHourlyImpl(
      temp: (json['temp'] as List<dynamic>).map((e) => e as num).toList(),
      pop: (json['pop'] as List<dynamic>).map((e) => e as num).toList(),
    );

Map<String, dynamic> _$$WeatherHourlyImplToJson(_$WeatherHourlyImpl instance) =>
    <String, dynamic>{'temp': instance.temp, 'pop': instance.pop};
