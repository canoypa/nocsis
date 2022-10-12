import 'package:flutter/material.dart';

class DuringClassScreen extends StatelessWidget {
  const DuringClassScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("1時間目", style: Theme.of(context).textTheme.titleLarge),
                Text("・"),
                Text("授業名", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            Text("90分", style: Theme.of(context).textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}
