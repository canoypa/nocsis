import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nocsis_classroom/components/clock.dart';
import 'package:nocsis_classroom/components/weather_graph.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WeatherGraph(),
        Padding(
          padding: EdgeInsets.all(24.r),
          child: Row(
            children: [
              const Expanded(child: HomeInfo()),
              SizedBox(width: 24.r),
              const Expanded(child: HomeSchedules()),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeInfo extends StatelessWidget {
  const HomeInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/weather/clear.svg",
                    width: 48.r,
                    height: 48.r,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "20°",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/weather/clear.svg",
                    width: 32.r,
                    height: 32.r,
                  ),
                  const Icon(Icons.navigate_next),
                  SvgPicture.asset(
                    "assets/images/weather/clear.svg",
                    width: 32.r,
                    height: 32.r,
                  ),
                  const Icon(Icons.navigate_next),
                  SvgPicture.asset(
                    "assets/images/weather/clear.svg",
                    width: 32.r,
                    height: 32.r,
                  ),
                ],
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "田中 太郎",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Clock(
                time: DateTime.now(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeSchedules extends StatelessWidget {
  const HomeSchedules({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Text(
              "まるまるの日",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
