import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/components/select_group_menu.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/routes/router.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class SettingsLayout extends ConsumerWidget {
  final Widget child;

  const SettingsLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);

    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;
    final colorScheme = Theme.of(context).colorScheme;
    final background = compact
        ? colorScheme.surface
        : colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: background,
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
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: background,
      ),
      body: compact
          ? _scrollable(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24))
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                ),
                child: _scrollable(
                  padding: EdgeInsets.all(width < 1200 ? 24 : 64),
                ),
              ),
            ),
    );
  }

  Widget _scrollable({required EdgeInsets padding}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: padding,
            child: child,
          ),
        );
      },
    );
  }
}
