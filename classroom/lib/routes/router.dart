import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_classroom/themes/display.dart';
import 'package:nocsis_classroom/pages/sign_in.dart';
import 'package:nocsis_classroom/screens/home.dart';

class GoRouterRefresher extends ChangeNotifier {
  late final StreamSubscription<dynamic> _auth;

  GoRouterRefresher() {
    notifyListeners();

    _auth = FirebaseAuth.instance
        .authStateChanges()
        .asBroadcastStream()
        .listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _auth.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: ScreenUtilInit(
            designSize: const Size(960, 540),
            builder: (context, child) {
              final theme = createDisplayTheme(context);

              return Theme(
                data: theme,
                child: const Scaffold(
                  body: HomeScreen(),
                ),
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: "/signin",
      pageBuilder: (context, state) {
        return const MaterialPage(
          child: SignInPage(),
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final isSignIn = user != null;

    if (!isSignIn && state.matchedLocation != "/signin") {
      if (state.path == null) {
        return "/signin";
      }

      return "/signin?continue=${state.path}";
    }

    if (isSignIn && state.matchedLocation == "/signin") {
      final continueUri = state.uri.queryParameters["continue"];
      final validUriPattern = RegExp(r"^/.+$");

      if (continueUri is String && validUriPattern.hasMatch(continueUri)) {
        return continueUri;
      }

      return "/";
    }

    return null;
  },
  refreshListenable: GoRouterRefresher(),
);
