import 'package:flutter/material.dart';

class DrawerLayout extends StatelessWidget {
  final Widget child;

  const DrawerLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Drawer(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            child: const Text('menu'),
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
