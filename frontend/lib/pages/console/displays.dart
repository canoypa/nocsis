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
            Text('登録方法', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('1. 表示に使う端末のブラウザで、次の URL を開く。'),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
              child: _DisplayUrlField(),
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
            const SizedBox(height: 32),
            Text('登録済みの端末', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            switch (displays) {
              AsyncData(:final value) when value.isEmpty => const _EmptyList(),
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

Uri _displayUrl() => Uri(
  scheme: Uri.base.scheme,
  host: Uri.base.host,
  port: Uri.base.hasPort ? Uri.base.port : null,
  path: '/display',
);

class _DisplayUrlField extends StatefulWidget {
  const _DisplayUrlField();

  @override
  State<_DisplayUrlField> createState() => _DisplayUrlFieldState();
}

class _DisplayUrlFieldState extends State<_DisplayUrlField> {
  final _controller = TextEditingController(text: _displayUrl().toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: IconButton(
            tooltip: 'URL をコピー',
            onPressed: () => _copyDisplayUrl(context),
            icon: const Icon(Symbols.content_copy),
          ),
        ),
      ),
    );
  }
}

Future<void> _copyDisplayUrl(BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: _displayUrl().toString()));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('URL をコピーしました')));
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

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

/// backend は UTF-16 の長さで数える。TextField の maxLength は書記素で数えるので合わない
bool _isValidName(String name) {
  final trimmed = name.trim();
  return trimmed.isNotEmpty && trimmed.length <= 50;
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
      (_name.text.trim().isEmpty || _isValidName(_name.text));

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

    final int? status;
    try {
      final client = await ref.read(apiClientProvider.future);
      final response = await client.apiV1GroupsGroupIdDisplaysPost(
        groupId: widget.groupId,
        body: DisplayCreateJson(code: _code.text, name: _name.text.trim()),
      );
      status = response.isSuccessful ? null : response.statusCode;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = '登録できませんでした。';
      });
      return;
    }
    if (!mounted) return;

    if (status == null) {
      ref.invalidate(displaysProvider(widget.groupId));
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitting = false;
      _error = switch (status) {
        404 => 'コードが違うか、期限が切れています。ディスプレイのコードを確かめてください。',
        429 => '間違いが続いたため、少し時間をおいてから入力してください。',
        _ => '登録できませんでした。',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Symbols.tv),
      title: const Text('コードで登録'),
      content: SizedBox(
        width: _CodeField.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ディスプレイに表示されているコードを入力してください。'),
            const SizedBox(height: 24),
            _CodeField(
              controller: _code,
              errorText: _error,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _name,
              maxLength: 50,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _canSubmit ? _submit() : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '名前（任意）',
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

/// 入力欄は1つのまま、見た目だけ6マスに描く。貼り付けや削除を普通の入力欄のまま扱える
class _CodeField extends StatefulWidget {
  static const length = 6;
  static const _boxWidth = 56.0;
  static const _gap = 8.0;
  static const _groupGap = 24.0;
  static const width = _boxWidth * length + _gap * (length - 2) + _groupGap;

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _CodeField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  @override
  State<_CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<_CodeField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.controller.text;
    final hasError = widget.errorText != null;
    final current = _focusNode.hasFocus
        ? text.length.clamp(0, _CodeField.length - 1)
        : null;

    Widget box(int i) {
      final isCurrent = i == current;
      final color = hasError
          ? colorScheme.error
          : isCurrent
          ? colorScheme.primary
          : colorScheme.outline;

      return Container(
        width: _CodeField._boxWidth,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: isCurrent ? 2 : 1),
        ),
        child: Text(
          i < text.length ? text[i] : '',
          style: textTheme.headlineMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _CodeField.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: i == 3 ? _CodeField._groupGap : _CodeField._gap,
                    ),
                  box(i),
                ],
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  showCursor: false,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_CodeField.length),
                  ],
                  onChanged: widget.onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'コード',
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
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

  bool get _canSubmit => !_submitting && _isValidName(_name.text);

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

    bool succeeded;
    try {
      final client = await ref.read(apiClientProvider.future);
      final response = await client.apiV1GroupsGroupIdDisplaysDisplayIdPatch(
        groupId: widget.groupId,
        displayId: widget.display.id,
        body: DisplayPatchJson(name: _name.text.trim()),
      );
      succeeded = response.isSuccessful;
    } catch (_) {
      succeeded = false;
    }
    if (!mounted) return;

    if (succeeded) {
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
