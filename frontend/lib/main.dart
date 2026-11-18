import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:nocsis/core/client_commit.dart';
import 'package:nocsis/core/error_reporter.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/themes/app.dart';

import 'firebase_options.dart';

void main() {
  final reporter = ErrorReporter(
    client: http.Client(),
    baseUrl: Uri.parse(apiBaseUrl),
    commit: buildCommit,
    currentPath: () => Uri.base.path,
  );

  // Web では PlatformDispatcher.onError が呼ばれないので、非同期のエラーはゾーンで拾う。
  // 初期化から runApp までを同じゾーンに入れる。分けると Flutter がゾーンの食い違いを警告する。
  runZonedGuarded(() => _main(reporter), (error, stack) {
    unawaited(reporter.report(error, stack));
    // ゾーンで拾うとブラウザのコンソールに出なくなるので、外側に渡して出す
    Zone.root.handleUncaughtError(error, stack);
  });
}

Future<void> _main(ErrorReporter reporter) async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 画像の読み込み失敗など、Flutter が報告するまでもないとしたもの
    if (details.silent) {
      return;
    }
    unawaited(reporter.report(details.exception, details.stack));
  };

  usePathUrlStrategy();

  // Firebase の初期化と、初回の認証状態の取得を待つ
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) => FirebaseAuth.instance.authStateChanges().first);

  // DateTime の日本語フォーマット初期化
  initializeDateFormatting("ja_JP");

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nocsis',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
