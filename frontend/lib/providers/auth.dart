import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase.dart';

part 'auth.g.dart';

@riverpod
Stream<User?> auth(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}
