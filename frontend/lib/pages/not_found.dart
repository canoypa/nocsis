import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/routes/router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("404: Page not found"),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("Home"),
              onPressed: () {
                final groupId =
                    GoRouter.of(context).state.pathParameters['groupId']!;
                PersonalHomeRoute(groupId).go(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
