import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase.dart';

part 'user.g.dart';

@riverpod
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
