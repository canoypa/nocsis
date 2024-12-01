import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/home_info.dart';
import 'package:nocsis/components/home_schedules.dart';
import 'package:nocsis/components/weather_graph.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/providers/during_class_data.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/screens/during_class.dart';
import 'package:nocsis/themes/display.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMouseMoving = false;
  Timer? _mouseTimer;

  void _onMouseMove(PointerEvent details) {
    setState(() {
      _isMouseMoving = true;
    });

    _mouseTimer?.cancel();
    _mouseTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isMouseMoving = false;
      });
    });
  }

  @override
  void dispose() {
    _mouseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duringClassData = ref.watch(duringClassDataProvider).value;

    return Scaffold(
      body: MouseRegion(
        onHover: _onMouseMove,
        child: Stack(
          children: [
            ScreenUtilInit(
                designSize: const Size(960, 540),
                builder: (context, child) {
                  final theme = createDisplayTheme(context);

                  return Theme(
                    data: theme,
                    child: Stack(
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
                    ),
                  );
                }),
            AnimatedOpacity(
              opacity: _isMouseMoving ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: const Text('Nocsis 起動時に Classroom を起動する'),
                          trailing: Switch(
                            value: true,
                            onChanged: (v) {},
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text('Classroom を終了する'),
                          onTap: () {
                            if (GoRouter.of(context).canPop()) {
                              GoRouter.of(context).pop();
                            } else {
                              const ConsoleTopRoute().go(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
