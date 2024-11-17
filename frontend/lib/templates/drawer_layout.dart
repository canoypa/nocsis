import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/routes/router.dart';

class DrawerLayout extends StatelessWidget {
  final Widget title;
  final Widget child;
  final int navigationIndex;
  final void Function(int) onDestinationSelected;
  final List<Widget> navigationItems;

  const DrawerLayout({
    super.key,
    required this.title,
    required this.child,
    required this.navigationIndex,
    required this.onDestinationSelected,
    required this.navigationItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              const HomeRoute().go(context);
            }
          },
        ),
        actions: const [AccountMenu()],
        title: title,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationDrawer(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            selectedIndex: navigationIndex,
            onDestinationSelected: onDestinationSelected,
            children: navigationItems,
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
                padding: const EdgeInsets.all(64),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
