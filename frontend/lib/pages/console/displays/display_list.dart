import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/skeleton.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/displays/rename_dialog.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/displays.dart';

class EmptyDisplayList extends StatelessWidget {
  const EmptyDisplayList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Text(
          'まだありません。',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// 読み込み中の [DisplayList]。端末の数は分からないので 2 行出す
class DisplayListSkeleton extends StatelessWidget {
  const DisplayListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Skeleton(
        child: Column(
          children: [
            for (final (index, width) in [140.0, 100.0].indexed) ...[
              if (index > 0)
                Divider(height: 1, color: colorScheme.outlineVariant),
              ListTile(
                leading: const SkeletonBlock(width: 24, height: 24),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBlock(width: width),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DisplayList extends StatelessWidget {
  final String groupId;
  final List<Display> displays;

  const DisplayList({super.key, required this.groupId, required this.displays});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, display) in displays.indexed) ...[
            if (index > 0)
              Divider(height: 1, color: colorScheme.outlineVariant),
            if (display.removedAt == null)
              _ActiveTile(groupId: groupId, display: display)
            else
              _RemovedTile(groupId: groupId, display: display),
          ],
        ],
      ),
    );
  }
}

class _ActiveTile extends StatelessWidget {
  final String groupId;
  final Display display;

  const _ActiveTile({required this.groupId, required this.display});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Symbols.tv),
      title: Text(display.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '名前を変更',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) =>
                  RenameDisplayDialog(groupId: groupId, display: display),
            ),
            icon: const Icon(Symbols.edit),
          ),
          IconButton(
            tooltip: '登録を解除',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('「${display.name}」の登録を解除しますか？'),
                  content: const Text(
                    'この端末には予定や天気が表示されなくなります。また使うときは登録し直してください。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('登録を解除'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;

              await _remove(
                context,
                groupId,
                display.id,
                failure: '登録を解除できませんでした。',
              );
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
    );
  }
}

class _RemovedTile extends StatelessWidget {
  final String groupId;
  final Display display;

  const _RemovedTile({required this.groupId, required this.display});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colorScheme.surfaceContainer,
      leading: Icon(Symbols.tv_off, color: colorScheme.onSurfaceVariant),
      title: Text(
        display.name,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      subtitle: const Text('登録が解除されています。使うときは端末で登録し直してください。'),
      trailing: IconButton(
        tooltip: '閉じる',
        onPressed: () =>
            _remove(context, groupId, display.id, failure: '一覧から除けませんでした。'),
        icon: const Icon(Symbols.close),
      ),
    );
  }
}

Future<void> _remove(
  BuildContext context,
  String groupId,
  String displayId, {
  required String failure,
}) async {
  // 応答を待つあいだに行が消えていることがあるので、行の ref は使わない
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);

  try {
    final client = await container.read(apiClientProvider.future);
    final response = await client.apiV1GroupsGroupIdDisplaysDisplayIdDelete(
      groupId: groupId,
      displayId: displayId,
    );
    if (!response.isSuccessful && response.statusCode != 404) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failure)));
  }
  container.invalidate(displaysProvider(groupId));
}
