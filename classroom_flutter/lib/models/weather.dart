import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required WeatherCurrent current,
    required WeatherHourly hourly,
    required List<String> threeHour,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

@freezed
class WeatherCurrent with _$WeatherCurrent {
  const factory WeatherCurrent({
    required String name,
    required int temp,
  }) = _WeatherCurrent;

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) =>
      _$WeatherCurrentFromJson(json);
}

@freezed
class WeatherHourly with _$WeatherHourly {
  const factory WeatherHourly({
    required List<num> temp,
    required List<num> pop,
  }) = _WeatherHourly;

  factory WeatherHourly.fromJson(Map<String, dynamic> json) =>
      _$WeatherHourlyFromJson(json);
}
