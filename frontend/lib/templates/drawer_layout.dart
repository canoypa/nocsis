import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/components/select_group_menu.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/routes/router.dart';

class DrawerLayout extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              PersonalHomePageRoute(groupId).go(context);
            }
          },
        ),
        actions: const [SelectGroupMenu(), AccountMenu()],
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
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        padding: const EdgeInsets.all(64),
                        child: child,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
