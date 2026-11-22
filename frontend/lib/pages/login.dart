import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/login_form.dart';
import 'package:nocsis/core/window_size_class.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<bool> _passwordLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
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
      return false;
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
    final compact = context.windowSizeClass < .medium;

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: compact ? Alignment.topCenter : Alignment.center,
          child: SingleChildScrollView(
            padding: compact
                ? const EdgeInsets.fromLTRB(16, 48, 16, 24)
                : const EdgeInsets.all(24),
            child: LoginForm(
              onGoogleLogin: () => _googleLogin(context),
              onPasswordLogin: (email, password) =>
                  _passwordLogin(context, email, password),
            ),
          ),
        ),
      ),
    );
  }
}
