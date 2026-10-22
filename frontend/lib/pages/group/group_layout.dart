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
      overrides: [
        // 読み手はこの ProviderScope 配下のウィジェットだけだが、go_router の
        // シェルルートを挟むので dependencies を宣言しても lint が辿れない。
        // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
        currentGroupIdProvider.overrideWithValue(groupId),
      ],
      child: navigator,
    );
  }
}
