import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/providers/firebase.dart';

class NoGroupPage extends ConsumerWidget {
  const NoGroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "参加しているグループがありません",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text("グループの管理者に追加を依頼してください。"),
              const SizedBox(height: 32),
              OutlinedButton(
                child: const Text("ログアウト"),
                onPressed: () => ref.read(firebaseAuthProvider).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
