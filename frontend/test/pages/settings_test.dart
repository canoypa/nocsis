import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/providers/firebase.dart';

class _Provider extends Fake implements UserInfo {
  @override
  final String providerId;

  @override
  final String? email;

  _Provider(this.providerId, {this.email});
}

class _IdToken extends Fake implements IdTokenResult {
  @override
  final DateTime authTime;

  @override
  String get signInProvider => 'google.com';

  @override
  Map<String, dynamic>? get claims => null;

  _IdToken(this.authTime);
}

/// 再認証を求める時間よりずっと前
final _longAgo = DateTime(2020);

MockUser googleUser({List<UserInfo> extra = const []}) => MockUser(
  email: 'taro@example.com',
  providerData: [
    _Provider('google.com', email: 'taro.google@example.com'),
    ...extra,
  ],
  idTokenResult: _IdToken(_longAgo),
);

MockUser userFailingPasswordUpdate(String code) {
  final user = googleUser();
  whenCalling(Invocation.method(#updatePassword, [anything]))
      .on(user)
      .thenThrow(FirebaseAuthException(code: code));
  return user;
}

void main() {
  Future<void> pumpSettings(
    WidgetTester tester,
    MockUser user, {
    double width = 1280,
  }) async {
    tester.view.physicalSize = Size(width, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(
            MockFirebaseAuth(signedIn: true, mockUser: user),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsTopPage())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('メールアドレスと連携している Google アカウントを出す', (tester) async {
    await pumpSettings(tester, googleUser());

    expect(find.text('taro@example.com'), findsOneWidget);
    expect(find.text('taro.google@example.com'), findsOneWidget);
  });

  Finder passwordRowButton(String label) => find.descendant(
    of: find.ancestor(of: find.text('パスワード'), matching: find.byType(Row)),
    matching: find.text(label),
  );

  testWidgets('パスワードが無いときは「設定する」を出す', (tester) async {
    await pumpSettings(tester, googleUser());

    expect(passwordRowButton('設定する'), findsOneWidget);
  });

  testWidgets('パスワードがあるときは「変更する」を出す', (tester) async {
    await pumpSettings(tester, googleUser(extra: [_Provider('password')]));

    expect(passwordRowButton('変更する'), findsOneWidget);
  });

  testWidgets('新しいメールアドレスを入れて確かめると、そのアドレスに確認を送ってダイアログが閉じる', (tester) async {
    final user = googleUser();
    whenCalling(
      Invocation.method(#verifyBeforeUpdateEmail, [
        isNot('new@example.com'),
        anything,
      ]),
    ).on(user).thenThrow(FirebaseAuthException(code: 'invalid-email'));
    await pumpSettings(tester, user);

    await tester.tap(find.text('変更する'));
    await tester.pumpAndSettle();
    expect(find.text('メールアドレスを変更する'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'new@example.com');
    await tester.tap(find.text('確認する'));
    await tester.pumpAndSettle();

    expect(find.text('メールアドレスを変更する'), findsNothing);
  });

  group('パスワードを設定する', () {
    Future<void> openDialog(WidgetTester tester, MockUser user) async {
      await pumpSettings(tester, user);
      await tester.tap(find.text('設定する'));
      await tester.pumpAndSettle();
    }

    Finder submit() => find.widgetWithText(FilledButton, '設定する');

    testWidgets('空のまま設定しようとすると、入力を求める', (tester) async {
      await openDialog(tester, googleUser());

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text('パスワードを入力してください。'), findsOneWidget);
    });

    testWidgets('弱いパスワードは、弱すぎると伝える', (tester) async {
      await openDialog(tester, userFailingPasswordUpdate('weak-password'));

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text('パスワードが弱すぎます。'), findsOneWidget);
    });

    testWidgets('最近ログインしていないときは、もう一度ログインを求める', (tester) async {
      await openDialog(
        tester,
        userFailingPasswordUpdate('requires-recent-login'),
      );

      await tester.enterText(find.byType(TextField), 'a-strong-password');
      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text('続けるには、もう一度ログインしてください。'), findsOneWidget);
    });

    testWidgets('入力したパスワードを設定できたら、ダイアログが閉じる', (tester) async {
      final user = googleUser();
      whenCalling(
        Invocation.method(#updatePassword, [isNot('a-strong-password')]),
      ).on(user).thenThrow(FirebaseAuthException(code: 'internal-error'));
      await openDialog(tester, user);

      await tester.enterText(find.byType(TextField), 'a-strong-password');
      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text('パスワードを設定する'), findsNothing);
    });
  });

  testWidgets('最近ログインしていないときに別アカウントと連携しようとすると、先にもう一度ログインを求める', (tester) async {
    await pumpSettings(tester, googleUser());

    await tester.tap(find.text('別アカウントと連携する'));
    await tester.pumpAndSettle();

    expect(find.text('続けるには、もう一度ログインしてください。'), findsOneWidget);
  });

  group('スマホの幅', () {
    testWidgets('メールアドレスの変更は全画面で開き、閉じるボタンで閉じられる', (tester) async {
      await pumpSettings(tester, googleUser(), width: 599);

      await tester.tap(find.text('変更する'));
      await tester.pumpAndSettle();
      expect(find.text('メールアドレスを変更する'), findsWidgets);

      await tester.tap(find.byTooltip('閉じる'));
      await tester.pumpAndSettle();

      expect(find.text('メールアドレスを変更する'), findsNothing);
    });

    testWidgets('もう一度ログインを求めるときも、閉じるボタンで閉じられる', (tester) async {
      await pumpSettings(
        tester,
        userFailingPasswordUpdate('requires-recent-login'),
        width: 599,
      );
      await tester.tap(find.text('設定する'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'a-strong-password');
      await tester.tap(find.widgetWithText(FilledButton, '設定する'));
      await tester.pumpAndSettle();
      expect(find.text('続けるには、もう一度ログインしてください。'), findsOneWidget);

      await tester.tap(find.byTooltip('閉じる'));
      await tester.pumpAndSettle();

      expect(find.text('続けるには、もう一度ログインしてください。'), findsNothing);
    });
  });

  testWidgets('広い幅ではダイアログを全画面にしない', (tester) async {
    await pumpSettings(tester, googleUser());

    await tester.tap(find.text('変更する'));
    await tester.pumpAndSettle();

    expect(find.text('メールアドレスを変更する'), findsWidgets);
    expect(find.byTooltip('閉じる'), findsNothing);
  });
}
