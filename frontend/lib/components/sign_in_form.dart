import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInForm extends StatefulWidget {
  static const _defaultFormTitle = 'サインイン';
  static const _defaultFormDescription = 'Nocsis を使用するには、サインインする必要があります。';

  final String title;
  final String description;
  final VoidCallback onGoogleSignIn;
  final void Function(String email, String password) onPasswordSignIn;

  const SignInForm({
    super.key,
    this.title = _defaultFormTitle,
    this.description = _defaultFormDescription,
    required this.onGoogleSignIn,
    required this.onPasswordSignIn,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool invisiblePassword = true;

  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();

  _togglePasswordVisibility() {
    setState(() {
      invisiblePassword = invisiblePassword ? false : true;
    });
  }

  _passwordVisibilityIcon() {
    if (invisiblePassword) {
      return Icons.visibility_off_outlined;
    } else {
      return Icons.visibility_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.all(64),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/Icon-192.png", width: 64),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: widget.onGoogleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/google.svg", width: 18),
                      const SizedBox(width: 8),
                      const Text("Google で続行"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'または',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailFieldController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'メールアドレス',
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordFieldController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'パスワード',
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(_passwordVisibilityIcon()),
                    ),
                  ),
                  obscureText: invisiblePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      widget.onPasswordSignIn(
                        emailFieldController.text,
                        passwordFieldController.text,
                      );
                    },
                    child: const Text('サインイン'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
