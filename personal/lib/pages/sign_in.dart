import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  _signIn(BuildContext context) async {
    try {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("サインイン出来ませんでした"),
        ),
      );
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
              Image.asset("assets/images/Icon-192.png", width: 56),
              const SizedBox(height: 8),
              const Text("Nocsis", style: TextStyle(fontSize: 40)),
              const SizedBox(height: 48),
              Text(
                "Nocsis を使用するには、サインインする必要があります。",
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () => _signIn(context),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 64),
                  ),
                ),
                child: const Text("サインイン"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
