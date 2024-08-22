import 'package:flutter/material.dart';
import 'package:nocsis_classroom/components/clock.dart';
import 'package:nocsis_classroom/components/daydudy.dart';
import 'package:nocsis_classroom/components/weather_info.dart';

class HomeInfo extends StatelessWidget {
  const HomeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: WeatherInfo(),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Daydudy(),
              Clock(),
            ],
          ),
        ),
      ],
    );
  }
}