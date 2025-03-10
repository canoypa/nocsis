// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weather _$WeatherFromJson(Map<String, dynamic> json) => _Weather(
  current: WeatherCurrent.fromJson(json['current'] as Map<String, dynamic>),
  hourly: WeatherHourly.fromJson(json['hourly'] as Map<String, dynamic>),
  threeHour:
      (json['threeHour'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$WeatherToJson(_Weather instance) => <String, dynamic>{
  'current': instance.current,
  'hourly': instance.hourly,
  'threeHour': instance.threeHour,
};

_WeatherCurrent _$WeatherCurrentFromJson(Map<String, dynamic> json) =>
    _WeatherCurrent(
      name: json['name'] as String,
      temp: (json['temp'] as num).toInt(),
    );

Map<String, dynamic> _$WeatherCurrentToJson(_WeatherCurrent instance) =>
    <String, dynamic>{'name': instance.name, 'temp': instance.temp};

_WeatherHourly _$WeatherHourlyFromJson(Map<String, dynamic> json) =>
    _WeatherHourly(
      temp: (json['temp'] as List<dynamic>).map((e) => e as num).toList(),
      pop: (json['pop'] as List<dynamic>).map((e) => e as num).toList(),
    );

Map<String, dynamic> _$WeatherHourlyToJson(_WeatherHourly instance) =>
    <String, dynamic>{'temp': instance.temp, 'pop': instance.pop};
