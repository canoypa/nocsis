import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';
import 'package:nocsis/pages/console/displays/display_list.dart';
import 'package:nocsis/pages/console/displays/register_dialog.dart';
import 'package:nocsis/pages/console/displays/url_field.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/displays.dart';
import 'package:nocsis/routes/router.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class ConsoleDisplaysPage extends ConsumerWidget {
  const ConsoleDisplaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final displays = ref.watch(displaysProvider(groupId));
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('教室ディスプレイ'),
            const SizedBox(height: 24),
            const Text('教室に予定や天気を出しておく画面です。'),
            const SizedBox(height: 16),
            Text('登録方法', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('1. 表示に使う端末のブラウザで、次の URL を開く。'),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
              child: DisplayUrlField(),
            ),
            const Text('2. 表示された QR コードをスマートフォンで読み取る。'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => RegisterDisplayDialog(groupId: groupId),
                  ),
                  icon: const Icon(Symbols.keyboard),
                  label: const Text('コードで登録'),
                ),
                OutlinedButton.icon(
                  onPressed: () => ClassroomPageRoute(groupId).go(context),
                  icon: const Icon(Symbols.open_in_new),
                  label: const Text('この端末で表示'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('登録済みの端末', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            switch (displays) {
              AsyncData(:final value) when value.isEmpty =>
                const EmptyDisplayList(),
              AsyncData(:final value) => DisplayList(
                groupId: groupId,
                displays: value,
              ),
              AsyncError() => const Text('教室ディスプレイを読み込めませんでした。'),
              _ => const DisplayListSkeleton(),
            },
          ],
        ),
      ),
    );
  }
}
