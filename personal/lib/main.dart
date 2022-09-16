import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nocsis_personal/core/router.dart';
import 'package:nocsis_personal/core/theme.dart';
import 'package:nocsis_personal/firebase_options.dart';
import 'package:nocsis_personal/pages/layout.dart';

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
      builder: (_, child) => AppLayout(child: child!),
    );
  }
}
