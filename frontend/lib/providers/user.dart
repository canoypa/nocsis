import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase.dart';

part 'user.g.dart';

// 購読を止めない。firebase_auth_web は userChanges と idTokenChanges の購読を止める順番によって、
// 止めるところで null を参照して落ちる
@Riverpod(keepAlive: true)
Stream<User?> userChangesStream(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges();
}

@riverpod
User? currentUser(Ref ref) {
  ref.watch(userChangesStreamProvider);

  final auth = ref.watch(firebaseAuthProvider);
  return auth.currentUser;
}

@riverpod
User authenticatedUser(Ref ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return user;
}
