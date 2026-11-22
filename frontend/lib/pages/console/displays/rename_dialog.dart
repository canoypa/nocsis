import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/displays/display_name.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/displays.dart';

class RenameDisplayDialog extends ConsumerStatefulWidget {
  final String groupId;
  final Display display;

  const RenameDisplayDialog({
    super.key,
    required this.groupId,
    required this.display,
  });

  @override
  ConsumerState<RenameDisplayDialog> createState() =>
      _RenameDisplayDialogState();
}

class _RenameDisplayDialogState extends ConsumerState<RenameDisplayDialog> {
  late final _name = TextEditingController(text: widget.display.name);
  bool _submitting = false;
  String? _error;

  bool get _canSubmit => !_submitting && isValidDisplayName(_name.text);

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
