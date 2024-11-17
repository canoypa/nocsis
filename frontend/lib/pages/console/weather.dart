import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleWeatherRoute extends GoRouteData {
  const ConsoleWeatherRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleWeatherPage(),
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

class ConsoleWeatherPage extends StatelessWidget {
  const ConsoleWeatherPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '気象/室温データ連携',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            const Text('気象データや室温データの取得に関する設定を行えます。'),
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
            const SizedBox(height: 48),
            Text(
              'SwitchBot 温湿度計',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'トークン',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'トークン',
              ),
            ),
            const SizedBox(height: 24),
            const Text('室温データの取得に使用している SwitchBot 温湿度計のデバイス ID を入力してください。'),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'デバイス 1',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'デバイス 2',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'デバイス 3',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
