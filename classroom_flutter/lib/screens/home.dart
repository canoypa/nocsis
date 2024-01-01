import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis_classroom/components/home_info.dart';
import 'package:nocsis_classroom/components/home_schedules.dart';
import 'package:nocsis_classroom/components/weather_graph.dart';
import 'package:nocsis_classroom/providers/auth.dart';
import 'package:nocsis_classroom/providers/during_class_data.dart';
import 'package:nocsis_classroom/screens/during_class.dart';
import 'package:nocsis_classroom/screens/signin.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return user.when(
      data: (user) {
        final signedIn = user != null;

        if (!signedIn) {
          return const SignInScreen();
        }

        return _Home();
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (e, s) {
        print(e);

        return const Center(
          child: Text("エラーが発生しました"),
        );
      },
    );
  }
}

class _Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duringClassData = ref.watch(duringClassDataProvider).whenOrNull(
          data: (data) => data,
        );

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
