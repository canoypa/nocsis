import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/providers/during_class_data.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/screens/classroom.dart';
import 'package:nocsis/screens/during_class.dart';
import 'package:nocsis/themes/display.dart';

class ClassroomRoute extends GoRouteData {
  final String groupId;

  const ClassroomRoute(this.groupId);

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ClassroomPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

class ClassroomPage extends ConsumerStatefulWidget {
  const ClassroomPage({super.key});

  @override
  ConsumerState<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends ConsumerState<ClassroomPage> {
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
    final groupId = GoRouter.of(context).state.pathParameters['groupId']!;
    final duringClassData = ref
        .watch(duringClassDataProvider(groupId))
        .maybeWhen(data: (data) => data, orElse: () => null);

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
                        child: const ClassroomScreen(),
                      ),
                      AnimatedOpacity(
                        opacity: duringClassData == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: DuringClassScreen(data: duringClassData),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                          title: const Text('Classroom を終了する'),
                          onTap: () {
                            if (GoRouter.of(context).canPop()) {
                              GoRouter.of(context).pop();
                            } else {
                              final groupId =
                                  GoRouter.of(
                                    context,
                                  ).state.pathParameters['groupId']!;
                              ConsoleTopRoute(groupId).go(context);
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
