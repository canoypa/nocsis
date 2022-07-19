import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nocsis_personal/pages/error.dart';
import 'package:nocsis_personal/pages/main.dart';
import 'package:nocsis_personal/pages/sign_in.dart';

enum PagePath {
  home("/"),
  events("/events"),
  signin("/signin");

  final String path;

  const PagePath(this.path);
}

// メインページの key
// パス違うページを同一ページとみなす
const mainPageKey = ValueKey("MainPage");

final router = GoRouter(
  // url をパス方式にする
  urlPathStrategy: UrlPathStrategy.path,

  routes: [
    GoRoute(
      path: PagePath.home.path,
      pageBuilder: (context, state) => MaterialPage(
        key: mainPageKey,
        child: MainPage(loc: state.subloc),
      ),
    ),
    GoRoute(
      path: PagePath.events.path,
      pageBuilder: (context, state) => MaterialPage(
        key: mainPageKey,
        child: MainPage(loc: state.subloc),
      ),
    ),
    GoRoute(
      path: PagePath.signin.path,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SignInPage(),
      ),
    )
  ],

  navigatorBuilder: (context, state, child) {
    // ステータスバーの色を surface に変更する
    return Title(
      title: "Nocsis",
      color: Theme.of(context).colorScheme.surface,
      child:
          // 必要な初期処理が終わるまでアプリを表示しない
          FutureBuilder(
        future: Future.wait([
          // DateTime の日本語フォーマット初期化
          initializeDateFormatting("ja_JP"),
          // 最初の認証までサインインしてないことにされるので待つ
          FirebaseAuth.instance.authStateChanges().first,
        ]),
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
  },

  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const ErrorPage(),
  ),

  redirect: (state) {
    final user = FirebaseAuth.instance.currentUser;
    final isSignIn = user != null;

    final currentLoc = state.subloc;

    if (!isSignIn && currentLoc != PagePath.signin.path) {
      return PagePath.signin.path;
    }

    if (isSignIn && currentLoc == PagePath.signin.path) {
      return PagePath.home.path;
    }

    return null;
  },

  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
);
