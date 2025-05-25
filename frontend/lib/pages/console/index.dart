import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/routes/router.dart';

class ConsoleTopPage extends StatelessWidget {
  const ConsoleTopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('管理コンソール', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            Text('かなり開発中です', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 48),
            OutlinedButton(
              child: const Text('Classroom を起動する'),
              onPressed: () {
                final groupId =
                    GoRouter.of(context).state.pathParameters['groupId']!;
                ClassroomPageRoute(groupId).go(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
