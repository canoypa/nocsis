import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocsis_personal/widget/day_schedule.dart';
import 'package:nocsis_personal/widget/toggle_day.dart';

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
      children: [
        ToggleDay(
          label: DateFormat("M月d日 (E)", "ja_JP").format(
            _parseEpochDay(_epochDay),
          ),
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
        Expanded(
          flex: 1,
          child: PageView.builder(
            controller: controller,
            itemBuilder: (context, index) {
              return DaySchedule(epochDay: index);
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
