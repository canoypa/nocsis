import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/providers/user.dart';

ProviderContainer createContainerWithUserChangesKeepAlive(
  FirebaseAuth mockAuth,
) {
  final container = ProviderContainer(
    overrides: [firebaseAuthProvider.overrideWithValue(mockAuth)],
  );
  final userChangesSubscription = container.listen<AsyncValue<User?>>(
    userChangesStreamProvider,
    (previous, next) {},
  );

  addTearDown(userChangesSubscription.close);
  addTearDown(container.dispose);
  return container;
}

Future<void> waitForUserChanges(ProviderContainer container) async {
  await container.read(userChangesStreamProvider.future);
}

void main() {
  group('currentUserProvider', () {
    group('ログインしていない場合', () {
      test('nullを返すこと', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final container = createContainerWithUserChangesKeepAlive(mockAuth);

        // Act
        await waitForUserChanges(container);

        // Assert
        final currentUser = container.read(currentUserProvider);
        expect(currentUser, isNull);
      });

      test('ログインするとUserを返すようになること', () async {
        // Arrange
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: false, mockUser: mockUser);
        final container = createContainerWithUserChangesKeepAlive(mockAuth);

        await waitForUserChanges(container);
        expect(container.read(currentUserProvider), isNull);

        // Act
        await mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        );

        await waitForUserChanges(container);

        // Assert
        final user = container.read(currentUserProvider);
        expect(user, isNotNull);
        expect(user, isA<User>());
        expect(user?.uid, equals('test-user'));
      });
    });

    group('ログインしている場合', () {
      test('Userを返すこと', () async {
        // Arrange
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final container = createContainerWithUserChangesKeepAlive(mockAuth);

        // Act
        await waitForUserChanges(container);

        // Assert
        final user = container.read(currentUserProvider);
        expect(user, isNotNull);
        expect(user, isA<User>());
        expect(user?.uid, equals('test-user'));
      });

      test('ログアウトするとnullを返すようになること', () async {
        // Arrange
        final mockUser = MockUser(uid: 'test-user', email: 'test@example.com');
        final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
        final container = createContainerWithUserChangesKeepAlive(mockAuth);

        await waitForUserChanges(container);
        expect(container.read(currentUserProvider), isNotNull);

        // Act
        await mockAuth.signOut();

        await waitForUserChanges(container);

        // Assert
        final user = container.read(currentUserProvider);
        expect(user, isNull);
      });
    });
  });
}
