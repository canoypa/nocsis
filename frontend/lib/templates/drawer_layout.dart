import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/components/select_group_menu.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/routes/router.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

enum _WindowSize {
  compact,
  medium,
  large;

  factory _WindowSize.of(double width) {
    if (width < 600) return compact;
    if (width < 1200) return medium;
    return large;
  }
}

@Dependencies([currentGroupId])
class DrawerLayout extends ConsumerWidget {
  final Widget title;
  final Widget child;
  final int navigationIndex;
  final void Function(int) onDestinationSelected;
  final List<NavigationDrawerDestination> navigationItems;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (_WindowSize.of(constraints.maxWidth)) {
          _WindowSize.compact => _buildCompact(context, groupId),
          _WindowSize.medium => _buildWithPane(
            context,
            groupId,
            navigation: _buildRail(context),
          ),
          _WindowSize.large => _buildWithPane(
            context,
            groupId,
            navigation: _buildDrawer(context),
          ),
        };
      },
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    String groupId, {
    VoidCallback? beforeNavigate,
  }) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_outlined),
      onPressed: () {
        final router = GoRouter.of(context);
        beforeNavigate?.call();
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(PersonalHomePageRoute(groupId).location);
        }
      },
    );
  }

  Widget _buildCompact(BuildContext context, String groupId) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'メニュー',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [AccountMenu()],
        title: title,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
      ),
      drawer: Builder(
        builder: (context) => NavigationDrawer(
          selectedIndex: navigationIndex,
          onDestinationSelected: (value) {
            Navigator.of(context).pop();
            onDestinationSelected(value);
          },
          header: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _buildBackButton(
                  context,
                  groupId,
                  // Drawer を閉じないと、Drawer 自身が canPop を true にして戻れない
                  beforeNavigate: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SelectGroupMenu(
                    isExpanded: true,
                    onSelected: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          children: navigationItems,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRail(BuildContext context) {
    return NavigationRail(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      selectedIndex: navigationIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0,
      scrollable: true,
      destinations: [
        for (final item in navigationItems)
          NavigationRailDestination(
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            label: item.label,
            disabled: !item.enabled,
          ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      selectedIndex: navigationIndex,
      onDestinationSelected: onDestinationSelected,
      children: navigationItems,
    );
  }

  Widget _buildWithPane(
    BuildContext context,
    String groupId, {
    required Widget navigation,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        leading: _buildBackButton(context, groupId),
        actions: const [SelectGroupMenu(), AccountMenu()],
        title: title,
        centerTitle: false,
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: colorScheme.surfaceContainer,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          navigation,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        padding: const EdgeInsets.all(24),
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
