import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleSlackRoute extends GoRouteData {
  const ConsoleSlackRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleSlackPage(),
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

class ConsoleSlackPage extends StatelessWidget {
  const ConsoleSlackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slack 連携', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            const Text('Slack への各種通知メッセージの送信を管理します。'),
            const SizedBox(height: 48),
            Text('トークン', style: Theme.of(context).textTheme.headlineMedium),
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
            const SizedBox(height: 48),
            Text('イベント通知', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('イベント通知を受け取る'),
                Switch(value: true, onChanged: null),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知時刻',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知するチャンネル',
              ),
            ),
            const SizedBox(height: 48),
            Text('日直通知', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('日直通知を受け取る'),
                Switch(value: true, onChanged: null),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知時刻',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知するチャンネル',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
