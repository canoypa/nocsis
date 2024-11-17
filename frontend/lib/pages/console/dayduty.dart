import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleDayDutyRoute extends GoRouteData {
  const ConsoleDayDutyRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleDayDutyPage(),
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

class ConsoleDayDutyPage extends StatelessWidget {
  const ConsoleDayDutyPage({
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
              '日直',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            const Text('日直の確認や周期の設定を行えます。'),
            const SizedBox(height: 48),
            Text(
              '開始日の設定',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              '出席番号1番の人が日直になる日付を入力してください。この日が基準になり、翌日は出席番号2番の人が日直になります。',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '開始日',
              ),
            )
          ],
        ),
      ),
    );
  }
}
