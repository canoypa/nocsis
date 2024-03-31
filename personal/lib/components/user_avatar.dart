import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_personal/providers/current_user.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSnapshot = ref.watch(currentUserProvider);

    return userSnapshot.when(
      data: (user) => CircleAvatar(
        foregroundImage:
            user!.photoURL != null ? NetworkImage(user.photoURL!) : null,
        child: user.displayName != null
            ? Text(user.displayName![0])
            : const Icon(Icons.person_outline),
      ),
      error: (error, a) => const CircleAvatar(
        child: Icon(Icons.person_outline),
      ),
      loading: () => const Icon(Icons.person_outline),
    );
  }
}
