import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    required WeatherCurrent current,
    required WeatherHourly hourly,
    required List<String> threeHour,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

@freezed
abstract class WeatherCurrent with _$WeatherCurrent {
  const factory WeatherCurrent({required String name, required int temp}) =
      _WeatherCurrent;

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) =>
      _$WeatherCurrentFromJson(json);
}

@freezed
abstract class WeatherHourly with _$WeatherHourly {
  const factory WeatherHourly({
    required List<num> temp,
    required List<num> pop,
  }) = _WeatherHourly;

  factory WeatherHourly.fromJson(Map<String, dynamic> json) =>
      _$WeatherHourlyFromJson(json);
}
