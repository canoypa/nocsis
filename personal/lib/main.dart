import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nocsis_personal/core/router.dart';
import 'package:nocsis_personal/core/theme.dart';
import 'package:nocsis_personal/firebase_options.dart';

void main() async {
  // url をパス形式にする
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Nocsis",
      color: const Color(0x001c1b1f),
      theme: lightTheme,
      darkTheme: darkTheme,
      routeInformationParser: router.parser,
      routerDelegate: router.delegate,
      builder: (context, child) {
        return Title(
          title: "Nocsis",
          color: Theme.of(context).colorScheme.surface,
          // 必要な初期処理が終わるまでアプリを表示しない
          child: FutureBuilder(
            future: Future.wait(
              [
                // DateTime の日本語フォーマット初期化
                initializeDateFormatting("ja_JP"),
                // 最初の認証までサインインしてないことにされるので待つ
                FirebaseAuth.instance.authStateChanges().first,
              ],
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return child!;
              }

              return Scaffold(
                body: Center(
                  child: snapshot.hasError
                      ? const Text("Something went wrong.")
                      : const CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
