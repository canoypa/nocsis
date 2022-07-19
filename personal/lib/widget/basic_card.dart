import 'package:flutter/material.dart';

class BasicCard extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const BasicCard({
    super.key,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          title: primary,
          subtitle: secondary,
        ),
      ),
    );
  }
}
