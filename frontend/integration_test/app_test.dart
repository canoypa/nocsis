import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nocsis/firebase_options.dart';
import 'package:nocsis/main.dart';
import 'package:nocsis/routes/router.dart';

// backend/e2e/seed.ts がエミュレータに作るデータと、backend/e2e/fake_external_apis.ts が
// 返す偽の予定。
const _email = 'e2e@example.com';
const _password = 'e2e-password';
const _groupId = 'e2e_group';
const _student = 'E2E 太郎';
const _className = 'E2E 国語';
const _eventName = 'E2E 遠足';

/// pumpAndSettle を使わない。時計とアニメーションが常に動いていて落ち着かない。
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('$finder が $timeout 以内に見つかりませんでした');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    await initializeDateFormatting('ja_JP');
    // ログイン画面は Google のポップアップしか持たず、ブラウザ自動操作では通せない。
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
    } on FirebaseException catch (e) {
      // profile ビルドは例外の型名が minify され、そのまま投げると原因が読めない。
      throw TestFailure('ログインに失敗しました: ${e.code} ${e.message}');
    }
  });

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  }

  // 失敗の中身は FlutterErrorDetails の toString では運ばない。profile ビルドではそれが空か
  // minify された型名になり、driver 側で原因が読めない。
  void e2eTest(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } catch (e, s) {
        final texts = tester
            .widgetList<RichText>(find.byType(RichText))
            .map((w) => w.text.toPlainText())
            .where((t) => t.trim().isNotEmpty)
            .toList();
        (binding.reportData ??= {})[description] = {
          'error': e is TestFailure ? e.message : '$e',
          'stack': '$s',
          'location': container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .toString(),
          'texts': texts,
        };
        rethrow;
      }
    });
  }

  e2eTest('トップを開くと参加しているグループの今日の授業とイベントが出る', (tester) async {
    await pumpApp(tester);

    await pumpUntilFound(tester, find.text(_className));
    await pumpUntilFound(tester, find.text(_eventName));
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/groups/$_groupId',
    );
  });

  e2eTest('教室画面に日直・授業・天気が出る', (tester) async {
    await pumpApp(tester);
    container.read(routerProvider).go('/groups/$_groupId/classroom');

    await pumpUntilFound(tester, find.text(_student));
    await pumpUntilFound(tester, find.text(_className));
    await pumpUntilFound(tester, find.text('℃'));
  });
}
