import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/displays.dart';
import 'package:nocsis/routes/dialog_page.dart';

class RemoveDisplayDialog extends StatelessWidget {
  final String groupId;
  final Display display;

  const RemoveDisplayDialog({
    super.key,
    required this.groupId,
    required this.display,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('「${display.name}」の登録を解除しますか？'),
      content: const Text('この端末には予定や天気が表示されなくなります。また使うときは登録し直してください。'),
      actions: [
        TextButton(
          onPressed: () => closeDialog(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            removeDisplay(
              context,
              groupId,
              display.id,
              failure: '登録を解除できませんでした。',
            );
            closeDialog(context);
          },
          child: const Text('登録を解除'),
        ),
      ],
    );
  }
}

Future<void> removeDisplay(
  BuildContext context,
  String groupId,
  String displayId, {
  required String failure,
}) async {
  // 応答を待つあいだに行やダイアログが消えるので、context は最初に読むだけにする
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

class ActiveDisplayBuilder extends ConsumerWidget {
  final String groupId;
  final String displayId;
  final Widget Function(Display display) builder;

  const ActiveDisplayBuilder({
    super.key,
    required this.groupId,
    required this.displayId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref
        .watch(displaysProvider(groupId))
        .value
        ?.where((d) => d.id == displayId && d.removedAt == null)
        .firstOrNull;
    return display == null ? const SizedBox.shrink() : builder(display);
  }
}
