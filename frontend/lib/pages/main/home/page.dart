import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/day_schedule.dart';
import 'package:nocsis/components/personal/toggle_day.dart';

class PersonalHomeRoute extends GoRouteData {
  const PersonalHomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMobile = MediaQuery.of(context).size.width < 1200;

    return CustomTransitionPage(
      key: state.pageKey,
      child: const MainView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (isMobile) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        }

        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainViewState();
  }
}

class _MainViewState extends State<MainView> {
  late PageController controller;

  late int _epochDay;

  Duration zoneDiff = const Duration(hours: 9);

  _MainViewState() {
    // 日本時間のエポック日を取得するため +9 時間
    final nowEpoch = DateTime.now().add(zoneDiff).millisecondsSinceEpoch;

    _epochDay = (nowEpoch / Duration.millisecondsPerDay).floor();

    controller = PageController(initialPage: _epochDay);
  }

  DateTime _parseEpochDay(int epochDay) {
    final int epoch = epochDay * Duration.millisecondsPerDay;

    // UTC として処理されるため -9 時間
    return DateTime.fromMillisecondsSinceEpoch(epoch).subtract(zoneDiff);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ToggleDay(
              label: DateFormat(
                "M月d日 (E)",
                "ja_JP",
              ).format(_parseEpochDay(_epochDay)),
              onClickLeft: () {
                controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
              onClickRight: () {
                controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemBuilder: (context, index) {
              // スワイプ範囲は表示範囲全体にするため、子要素のみサイズ制限
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 800,
                          minHeight: constraints.maxHeight,
                        ),
                        child: DaySchedule(epochDay: index),
                      ),
                    ),
                  );
                },
              );
            },
            onPageChanged: (value) {
              setState(() {
                _epochDay = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
