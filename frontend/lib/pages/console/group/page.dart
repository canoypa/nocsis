import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';
import 'package:nocsis/components/skeleton.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/group/group_name.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/group.dart';
import 'package:nocsis/providers/me.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

@Dependencies([currentGroupId])
class ConsoleGroupPage extends ConsumerWidget {
  const ConsoleGroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final group = ref.watch(groupProvider(groupId));

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 48,
          children: [
            const PageTitle('グループ'),
            switch (group) {
              // 保存のあとに取り直す間も、入力中の欄を作り直さない
              AsyncValue(:final value?) => _GroupNameForm(group: value),
              AsyncError() => const Text('グループを読み込めませんでした。'),
              _ => const Skeleton(
                child: SkeletonBlock(width: 400, height: 56, radius: 4),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _GroupNameForm extends ConsumerStatefulWidget {
  final Group group;

  const _GroupNameForm({required this.group});

  @override
  ConsumerState<_GroupNameForm> createState() => _GroupNameFormState();
}

class _GroupNameFormState extends ConsumerState<_GroupNameForm> {
  late final _name = TextEditingController(text: widget.group.name);
  bool _submitting = false;
  String? _error;

  bool get _canSubmit =>
      !_submitting &&
      _name.text.trim() != widget.group.name &&
      isValidGroupName(_name.text);

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
    final messenger = ScaffoldMessenger.of(context);

    bool succeeded;
    try {
      final client = await ref.read(apiClientProvider.future);
      final response = await client.apiV1GroupsIdPatch(
        id: widget.group.id,
        body: GroupPatchJson(name: _name.text.trim()),
      );
      succeeded = response.isSuccessful;
    } catch (_) {
      succeeded = false;
    }
    if (!mounted) return;

    if (succeeded) {
      _name.text = _name.text.trim();
      ref.invalidate(groupProvider(widget.group.id));
      // グループの切り替えメニューにも名前が出る
      ref.invalidate(meProvider);
      messenger.showSnackBar(const SnackBar(content: Text('グループ名を保存しました。')));
    }

    setState(() {
      _submitting = false;
      _error = succeeded ? null : 'グループ名を保存できませんでした。';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 文字数の表示が入力欄の下に場所をとるので、ボタンとの間は詰める
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        TextField(
          controller: _name,
          maxLength: 50,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _canSubmit ? _submit() : null,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'グループ名',
            errorText: _error,
          ),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
