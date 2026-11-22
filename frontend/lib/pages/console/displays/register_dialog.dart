import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/code_field.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/console/displays/display_name.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/displays.dart';

class RegisterDisplayDialog extends ConsumerStatefulWidget {
  final String groupId;

  const RegisterDisplayDialog({super.key, required this.groupId});

  @override
  ConsumerState<RegisterDisplayDialog> createState() =>
      _RegisterDisplayDialogState();
}

class _RegisterDisplayDialogState extends ConsumerState<RegisterDisplayDialog> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _canSubmit =>
      !_submitting &&
      RegExp(r'^\d{6}$').hasMatch(_code.text) &&
      (_name.text.trim().isEmpty || isValidDisplayName(_name.text));

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
        width: CodeField.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ディスプレイに表示されているコードを入力してください。'),
            const SizedBox(height: 24),
            CodeField(
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
