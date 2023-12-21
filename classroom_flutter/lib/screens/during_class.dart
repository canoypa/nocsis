import 'package:flutter/material.dart';
import 'package:nocsis_classroom/components/during_class_progress.dart';

class DuringClassScreen extends StatelessWidget {
  const DuringClassScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DuringClassProgress(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("1時間目", style: Theme.of(context).textTheme.titleSmall),
                  const Text("・"),
                  Text("授業名", style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              Text("90分", style: Theme.of(context).textTheme.displayLarge),
            ],
          ),
        ),
      ],
    );
  }
}
