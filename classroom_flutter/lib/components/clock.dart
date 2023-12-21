import 'dart:async';

import 'package:flutter/material.dart';

class Clock extends StatefulWidget {
  final DateTime time;

  const Clock({
    super.key,
    required this.time,
  });

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
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
    final baseStyle = Theme.of(context).textTheme.displayLarge;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: widget.time.hour.toString().padLeft(2, "0")),
          TextSpan(
            text: ":",
            style: TextStyle(
              color: !_visible ? baseStyle?.color?.withAlpha(127) : null,
            ),
          ),
          TextSpan(text: widget.time.minute.toString().padLeft(2, "0")),
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
