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
  final userAsync = ref.watch(userChangesStreamProvider);
  return userAsync.maybeWhen(data: (user) => user, orElse: () => null);
}
