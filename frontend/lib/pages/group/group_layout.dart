import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/providers/current_group_id.dart';

class GroupLayout extends StatelessWidget {
  final Widget navigator;
  final String groupId;

  const GroupLayout({
    super.key,
    required this.groupId,
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [currentGroupIdProvider.overrideWithValue(groupId)],
      child: navigator,
    );
  }
}
