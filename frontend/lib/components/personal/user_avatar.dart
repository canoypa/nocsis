import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/providers/auth.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSnapshot = ref.watch(authProvider);

    return userSnapshot.when(
      data: (user) => user == null
          ? const Icon(Symbols.person)
          : CircleAvatar(
              foregroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              onForegroundImageError: user.photoURL != null ? (_, _) {} : null,
              child: user.displayName?.isNotEmpty == true
                  ? Text(user.displayName![0])
                  : const Icon(Symbols.person),
            ),
      error: (error, a) => const CircleAvatar(child: Icon(Symbols.person)),
      loading: () => const Icon(Symbols.person),
    );
  }
}
