import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInForm extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onGoogleSignIn;

  const SignInForm({
    super.key,
    required this.title,
    required this.description,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/images/Icon-192.png", width: 64),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 24),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: onGoogleSignIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/google.svg", width: 18),
                const SizedBox(width: 8),
                const Text("Google で続行"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
