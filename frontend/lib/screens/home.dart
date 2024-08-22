import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis/components/home_info.dart';
import 'package:nocsis/components/home_schedules.dart';
import 'package:nocsis/components/weather_graph.dart';
import 'package:nocsis/providers/during_class_data.dart';
import 'package:nocsis/screens/during_class.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duringClassData = ref.watch(duringClassDataProvider).value;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: duringClassData == null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
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
          ),
        ),
        AnimatedOpacity(
          opacity: duringClassData == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: DuringClassScreen(data: duringClassData),
        ),
      ],
    );
  }
}
