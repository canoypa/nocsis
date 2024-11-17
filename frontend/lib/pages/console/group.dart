import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsoleGroupRoute extends GoRouteData {
  const ConsoleGroupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const ConsoleGroupPage(),
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

class ConsoleGroupPage extends StatelessWidget {
  const ConsoleGroupPage({
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
              'グループ',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            const Text('グループに関する情報を管理します。'),
            const SizedBox(height: 48),
            TextField(
              controller: TextEditingController(text: 'ITE'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'グループ名',
              ),
            )
          ],
        ),
      ),
    );
  }
}
