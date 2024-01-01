import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nocsis_classroom/providers/weather.dart';

class WeatherInfo extends ConsumerWidget {
  const WeatherInfo({super.key});

  _getWeatherIconPath(String weather) {
    switch (weather) {
      case "Clear":
        return "assets/images/weather/clear.svg";
      case "Clouds":
        return "assets/images/weather/clouds.svg";
      case "Rain":
        return "assets/images/weather/rain.svg";
      case "Snow":
        return "assets/images/weather/snow.svg";
      case "Atmosphere":
        return "assets/images/weather/atmosphere.svg";
      default:
        return "assets/images/weather/unknown.svg";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider).whenOrNull(
          data: (data) => data,
        );

    if (weather == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              _getWeatherIconPath(weather.current.name),
              width: 64.sp,
              height: 64.sp,
            ),
            const SizedBox(width: 16),
            Text(
              "${weather.current.temp}°",
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        Row(
          children: weather.threeHour
              .map(
                (e) => SvgPicture.asset(
                  _getWeatherIconPath(e),
                  width: 48.sp,
                  height: 48.sp,
                ),
              )
              .expand((e) => [e, Icon(Icons.navigate_next, size: 32.sp)])
              .toList()
            ..removeLast(),
        ),
      ],
    );
  }
}
