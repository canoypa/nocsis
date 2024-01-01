import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis_classroom/components/clock.dart';
import 'package:nocsis_classroom/components/daydudy.dart';
import 'package:nocsis_classroom/components/weather_graph.dart';
import 'package:nocsis_classroom/components/weather_info.dart';
import 'package:nocsis_classroom/providers/auth.dart';
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

class HomeInfo extends StatelessWidget {
  const HomeInfo({
    super.key,
  });

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
