import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nocsis/components/skeleton.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/weather.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class WeatherInfo extends ConsumerWidget {
  const WeatherInfo({super.key});

  String _getWeatherIconPath(String weather) {
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
    final groupId = ref.watch(currentGroupIdProvider);
    final snapshot = ref.watch(weatherProvider(groupId));
    final weather = snapshot.value;

    if (weather == null) {
      // 失敗した後の再試行中も isLoading になる。そのたびに明滅させない
      return snapshot.isLoading && !snapshot.hasError
          ? const _WeatherInfoSkeleton()
          : const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              _getWeatherIconPath(weather.current.name.value ?? 'Unknown'),
              width: 80.sp,
              height: 80.sp,
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.current.temp.round().toString(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text("℃", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ),
        Row(
          children:
              weather.threeHour
                  .map(
                    (e) => SvgPicture.asset(
                      _getWeatherIconPath(e.value ?? 'Unknown'),
                      width: 48.sp,
                      height: 48.sp,
                    ),
                  )
                  .expand((e) => [e, Icon(Symbols.navigate_next, size: 32.sp)])
                  .toList()
                ..removeLast(),
        ),
      ],
    );
  }
}

class _WeatherInfoSkeleton extends StatelessWidget {
  const _WeatherInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBlock(width: 80.sp, height: 80.sp, radius: 40.sp),
              const SizedBox(width: 16),
              const SkeletonBlock(width: 56, height: 36),
            ],
          ),
          SizedBox(height: 8.sp),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 32.sp,
            children: [
              for (var i = 0; i < 3; i++)
                SkeletonBlock(width: 48.sp, height: 48.sp, radius: 24.sp),
            ],
          ),
        ],
      ),
    );
  }
}
