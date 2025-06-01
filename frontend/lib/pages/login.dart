import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nocsis/components/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _passwordLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("ログイン出来ませんでした"),
          ),
        );
      }
    }
  }

  void _googleLogin(BuildContext context) async {
    try {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("ログイン出来ませんでした"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LoginForm(
                onGoogleLogin: () => _googleLogin(context),
                onPasswordLogin: (email, password) =>
                    _passwordLogin(context, email, password),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
