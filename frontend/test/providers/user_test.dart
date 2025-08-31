import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/providers/user.dart';

void main() {
  group('currentUserProvider', () {
    group('ログインしていない場合', () {
      test('nullを返すこと', () async {
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );

        await container.read(userChangesStreamProvider.future);

        final currentUser = container.read(currentUserProvider);
        expect(currentUser, isNull);

        container.dispose();
      });

      test('ログインするとUserを返すようになること', () async {
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: false, mockUser: mockUser);
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );

        await container.read(userChangesStreamProvider.future);
        expect(container.read(currentUserProvider), isNull);

        await mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        await container.read(userChangesStreamProvider.future);

        final user = container.read(currentUserProvider);
        expect(user, isNotNull);
        expect(user, isA<User>());
        expect(user?.uid, equals('test-user'));

        container.dispose();
      });
    });

    group('ログインしている場合', () {
      test('Userを返すこと', () async {
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );

        await container.read(userChangesStreamProvider.future);

        final user = container.read(currentUserProvider);
        expect(user, isNotNull);
        expect(user, isA<User>());
        expect(user?.uid, equals('test-user'));

        container.dispose();
      });

      test('ログアウトするとnullを返すようになること', () async {
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final container = ProviderContainer(
          overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
        );

        await container.read(userChangesStreamProvider.future);
        expect(container.read(currentUserProvider), isNotNull);

        await mockAuth.signOut();

        await container.read(userChangesStreamProvider.future);

        final user = container.read(currentUserProvider);
        expect(user, isNull);

        container.dispose();
      });
    });
  });
}
