import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/me.dart';

/// 管理者が、教室ディスプレイに出ている QR コードを読み取って開く
class DisplayRegisterPage extends ConsumerStatefulWidget {
  final String code;

  const DisplayRegisterPage({super.key, required this.code});

  @override
  ConsumerState<DisplayRegisterPage> createState() =>
      _DisplayRegisterPageState();
}

class _DisplayRegisterPageState extends ConsumerState<DisplayRegisterPage> {
  final _name = TextEditingController();
  String? _groupId;
  List<MembershipGroup> _groups = const [];

  String? get _selected => _groupId ?? _groups.firstOrNull?.id;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final name = _name.text.trim();
    // backend と同じく UTF-16 の長さで数える
    return !_submitting &&
        _selected != null &&
        name.isNotEmpty &&
        name.length <= 50;
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    int? status;
    try {
      final client = await ref.read(apiClientProvider.future);
      final response = await client.apiV1GroupsGroupIdDisplaysPost(
        groupId: _selected,
        body: DisplayCreateJson(code: widget.code, name: _name.text.trim()),
      );
      status = response.isSuccessful ? null : response.statusCode;
    } catch (_) {
      status = -1;
    }
    if (!mounted) return;

    if (status == null) {
      context.go('/groups/$_selected/console/displays');
      return;
    }

    setState(() {
      _submitting = false;
      _error = switch (status) {
        404 => 'コードの期限が切れています。ディスプレイの QR コードを読み取り直してください。',
        429 => '間違いが続いたため、少し時間をおいてから登録してください。',
        _ => '登録できませんでした。',
      };
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final uid = ref.watch(currentUidProvider);
    final me = uid == null ? null : ref.watch(meProvider(uid)).value;
    final groups = _groups = [
      for (final membership in me?.memberships ?? const <Membership>[])
        if (membership.permissions.contains(Permission.accessCreate))
          membership.group,
    ];
    final code = widget.code;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: _close),
        title: const Text('教室ディスプレイを登録'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'ディスプレイに表示されているコードと同じか確かめて、表示するグループを選んでください。',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'コード',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                code.length == 6
                    ? '${code.substring(0, 3)} ${code.substring(3)}'
                    : code,
                style: textTheme.headlineMedium?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 24),
              DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                label: const Text('グループ'),
                initialSelection: _selected,
                onSelected: (value) => setState(() => _groupId = value),
                dropdownMenuEntries: [
                  for (final group in groups)
                    DropdownMenuEntry(value: group.id, label: group.name),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                maxLength: 50,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '名前',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
