import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class SelectGroupMenu extends ConsumerWidget {
  const SelectGroupMenu({super.key});

  void _onChangedDropdown(String? groupId, BuildContext context) {
    if (groupId == null) return;

    final currentGroupId = GoRouter.of(context).state.pathParameters['groupId'];
    final newUri = GoRouter.of(context).state.uri.path
        .replaceFirst('/$currentGroupId', '/$groupId');

    GoRouter.of(context).go(newUri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final memberships = uid == null
        ? <Membership>[]
        : ref.watch(meProvider(uid)).value?.memberships ?? [];

    final groupId = ref.watch(currentGroupIdProvider);

    return DropdownButton(
      items: memberships
          .map(
            (membership) => DropdownMenuItem(
              value: membership.group.id,
              child: Text(membership.group.name),
            ),
          )
          .toList(),
      value: groupId,
      onChanged: (value) => _onChangedDropdown(value, context),
      underline: SizedBox(),
    );
  }
}
