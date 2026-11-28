import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/personal/user_avatar.dart';
import 'package:nocsis/providers/firebase.dart';

void main() {
  Future<MockFirebaseAuth> pumpSignedIn(
    WidgetTester tester, {
    String? displayName,
  }) async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', displayName: displayName),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseAuthProvider.overrideWithValue(auth)],
        child: const MaterialApp(home: Scaffold(body: UserAvatar())),
      ),
    );
    await tester.pump();
    return auth;
  }

  testWidgets('名前の頭文字を出す', (tester) async {
    await pumpSignedIn(tester, displayName: '佐々木');

    expect(find.text('佐'), findsOneWidget);
  });

  testWidgets('ログアウトしてユーザーが空になっても描ける', (tester) async {
    final auth = await pumpSignedIn(tester, displayName: '佐々木');

    await auth.signOut();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Symbols.person), findsOneWidget);
  });

  testWidgets('名前が空文字でも描ける', (tester) async {
    await pumpSignedIn(tester, displayName: '');

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Symbols.person), findsOneWidget);
  });
}
