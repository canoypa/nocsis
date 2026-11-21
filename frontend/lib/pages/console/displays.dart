import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
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
            Text('教室ディスプレイ', style: textTheme.displayMedium),
            const SizedBox(height: 24),
            const Text('教室に予定や天気を出しておく画面です。'),
            const SizedBox(height: 16),
            Text('追加のしかた', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '1. 表示に使う端末のブラウザで ${Uri.base.host}/display を開く。\n'
              '2. 表示された QR コードをスマートフォンで読み取る。',
              style: const TextStyle(height: 1.8),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _RegisterDialog(groupId: groupId),
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
            const SizedBox(height: 24),
            switch (displays) {
              AsyncData(:final value) when value.isEmpty =>
                const SizedBox.shrink(),
              AsyncData(:final value) => _DisplayList(
                groupId: groupId,
                displays: value,
              ),
              AsyncError() => const Text('教室ディスプレイを読み込めませんでした。'),
              _ => const LinearProgressIndicator(),
            },
          ],
        ),
      ),
    );
  }
}

class _DisplayList extends StatelessWidget {
  final String groupId;
  final List<Display> displays;

  const _DisplayList({required this.groupId, required this.displays});

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

class _ActiveTile extends ConsumerWidget {
  final String groupId;
  final Display display;

  const _ActiveTile({required this.groupId, required this.display});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              builder: (_) => _RenameDialog(groupId: groupId, display: display),
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

              await _remove(context, ref, groupId, display.id);
            },
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
    );
  }
}

class _RemovedTile extends ConsumerWidget {
  final String groupId;
  final Display display;

  const _RemovedTile({required this.groupId, required this.display});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onPressed: () => _remove(context, ref, groupId, display.id),
        icon: const Icon(Symbols.close),
      ),
    );
  }
}

Future<void> _remove(
  BuildContext context,
  WidgetRef ref,
  String groupId,
  String displayId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1GroupsGroupIdDisplaysDisplayIdDelete(
    groupId: groupId,
    displayId: displayId,
  );

  if (!response.isSuccessful && response.statusCode != 404) {
    messenger.showSnackBar(const SnackBar(content: Text('登録を解除できませんでした。')));
  }
  ref.invalidate(displaysProvider(groupId));
}

class _RegisterDialog extends ConsumerStatefulWidget {
  final String groupId;

  const _RegisterDialog({required this.groupId});

  @override
  ConsumerState<_RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends ConsumerState<_RegisterDialog> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _canSubmit =>
      !_submitting &&
      RegExp(r'^\d{6}$').hasMatch(_code.text) &&
      _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final client = await ref.read(apiClientProvider.future);
    final response = await client.apiV1GroupsGroupIdDisplaysPost(
      groupId: widget.groupId,
      body: DisplayCreateJson(code: _code.text, name: _name.text.trim()),
    );
    if (!mounted) return;

    if (response.isSuccessful) {
      ref.invalidate(displaysProvider(widget.groupId));
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitting = false;
      _error = switch (response.statusCode) {
        404 => 'コードが見つからないか、期限が切れています。',
        429 => 'しばらく待ってから入力し直してください。',
        _ => '登録できませんでした。',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('コードで登録'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ディスプレイに表示されている 6 桁のコードを入力してください。'),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'コード',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              maxLength: 50,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _canSubmit ? _submit() : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '名前',
                hintText: '例: 1年1組 黒板横',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('登録'),
        ),
      ],
    );
  }
}

class _RenameDialog extends ConsumerStatefulWidget {
  final String groupId;
  final Display display;

  const _RenameDialog({required this.groupId, required this.display});

  @override
  ConsumerState<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends ConsumerState<_RenameDialog> {
  late final _name = TextEditingController(text: widget.display.name);
  bool _submitting = false;
  String? _error;

  bool get _canSubmit => !_submitting && _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final client = await ref.read(apiClientProvider.future);
    final response = await client.apiV1GroupsGroupIdDisplaysDisplayIdPatch(
      groupId: widget.groupId,
      displayId: widget.display.id,
      body: DisplayPatchJson(name: _name.text.trim()),
    );
    if (!mounted) return;

    if (response.isSuccessful) {
      ref.invalidate(displaysProvider(widget.groupId));
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitting = false;
      _error = '名前を変更できませんでした。';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('名前を変更'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _name,
          autofocus: true,
          maxLength: 50,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: '名前',
            errorText: _error,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
