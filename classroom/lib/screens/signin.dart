import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nocsis",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 48),
          FilledButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(vertical: 32.sp, horizontal: 64.sp),
              ),
            ),
            child: const Text("サインイン"),
            onPressed: () => _signIn(context),
          ),
        ],
      ),
    );
  }
}
