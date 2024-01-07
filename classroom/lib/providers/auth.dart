import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
Stream<User?> auth(_) {
  return FirebaseAuth.instance.authStateChanges();
}
