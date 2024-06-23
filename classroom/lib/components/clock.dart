import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/providers/cron.dart';

class Clock extends ConsumerStatefulWidget {
  const Clock({super.key});

  @override
  ConsumerState<Clock> createState() => _ClockState();
}

class _ClockState extends ConsumerState<Clock> {
  bool _visible = true;

  late Timer _timer;

  @override
  initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _visible = !_visible);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 毎分更新
    ref.watch(cronProvider("* * * * *"));

    final time = DateTime.now();

    final baseStyle = Theme.of(context).textTheme.displayLarge;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: time.hour.toString().padLeft(2, "0")),
          TextSpan(
            text: ":",
            style: TextStyle(
              color: !_visible ? baseStyle?.color?.withAlpha(127) : null,
            ),
          ),
          TextSpan(text: time.minute.toString().padLeft(2, "0")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }
}
