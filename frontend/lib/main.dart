import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nocsis/routes/router.dart';
import 'package:nocsis/themes/app.dart';

import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();

  // Firebase の初期化と、初回の認証状態の取得を待つ
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) => FirebaseAuth.instance.authStateChanges().first);

  // DateTime の日本語フォーマット初期化
  initializeDateFormatting("ja_JP");

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseFunctions.instanceFor(region: "asia-northeast1")
        .useFunctionsEmulator("localhost", 5001);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nocsis',
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
    );
  }
}
