import 'package:flutter/material.dart';

class ConsoleWeatherPage extends StatelessWidget {
  const ConsoleWeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('気象データ連携', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            const Text('気象データの取得に関する設定を行えます。'),
            const SizedBox(height: 48),
            Text(
              '気象データを取得する地点',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const Text('天気/降水確率データを取得する地点の緯度経度を入力してください。'),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '緯度',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '経度',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
