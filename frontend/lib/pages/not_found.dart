import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/routes/router.dart';

class ErrorPage extends ConsumerWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("404: Page not found"),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("Home"),
              onPressed: () => PersonalHomePageRoute(groupId).go(context),
            ),
          ],
        ),
      ),
    );
  }
}
