import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/models/user_joined_groups.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/user_joined_groups.dart';

class SelectGroupMenu extends ConsumerWidget {
  const SelectGroupMenu({super.key});

  void _onChangedDropdown(String? groupId, BuildContext context) {
    if (groupId == null) return;

    final currentGroupId = GoRouter.of(context).state.pathParameters['groupId'];
    final newUri = GoRouter.of(
      context,
    ).state.uri.path.replaceFirst('/$currentGroupId', '/$groupId');

    GoRouter.of(context).go(newUri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userJoinedGroups = ref
        .watch(userJoinedGroupsProvider)
        .maybeWhen(
          data: (data) => data,
          orElse: () => UserJoinedGroups(groups: []),
        );

    final groupId = ref.watch(currentGroupIdProvider);

    return DropdownButton(
      items:
          userJoinedGroups.groups
              .map(
                (group) => DropdownMenuItem(
                  value: group.groupId,
                  child: Text(group.groupName),
                ),
              )
              .toList(),
      value: groupId,
      onChanged: (value) => _onChangedDropdown(value, context),
      underline: SizedBox(),
    );
  }
}
