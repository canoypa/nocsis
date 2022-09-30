import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Title(
      title: "Nocsis",
      color: Theme.of(context).colorScheme.surface,
      // 必要な初期処理が終わるまでアプリを表示しない
      child: FutureBuilder(
        future: Future.wait(
          [
            // DateTime の日本語フォーマット初期化
            initializeDateFormatting("ja_JP"),
            // 最初の認証を待つ
            FirebaseAuth.instance.authStateChanges().first,
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return child;
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
  }
}
