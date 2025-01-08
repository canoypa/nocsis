import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

@riverpod
Stream<User?> user(_) {
  return FirebaseAuth.instance.userChanges();
}
