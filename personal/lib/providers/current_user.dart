import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user.g.dart';

@riverpod
Stream<User?> currentUser(_) {
  return FirebaseAuth.instance.authStateChanges();
}
