import 'package:flutter/material.dart';

class ToggleDay extends StatelessWidget {
  final String label;
  final void Function() onClickRight;
  final void Function() onClickLeft;

  const ToggleDay({
    super.key,
    required this.label,
    required this.onClickRight,
    required this.onClickLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.navigate_before),
          padding: const EdgeInsets.all(16),
          onPressed: onClickLeft,
        ),
        Text(label),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          padding: const EdgeInsets.all(16),
          onPressed: onClickRight,
        ),
      ],
    );
  }
}
