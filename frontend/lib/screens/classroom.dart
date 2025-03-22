import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis/components/home_info.dart';
import 'package:nocsis/components/home_schedules.dart';
import 'package:nocsis/components/weather_graph.dart';

class ClassroomScreen extends StatelessWidget {
  const ClassroomScreen({super.key});

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
