import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginForm extends StatefulWidget {
  static const _defaultFormTitle = 'ログイン';
  static const _defaultFormDescription = 'Nocsis を使用するには、ログインする必要があります。';

  final String title;
  final String description;
  final VoidCallback onGoogleLogin;
  final void Function(String email, String password) onPasswordLogin;

  const LoginForm({
    super.key,
    this.title = _defaultFormTitle,
    this.description = _defaultFormDescription,
    required this.onGoogleLogin,
    required this.onPasswordLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();

  bool invisiblePassword = true;

  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      invisiblePassword = invisiblePassword ? false : true;
    });
  }

  IconData _passwordVisibilityIcon() {
    if (invisiblePassword) {
      return Icons.visibility_off_outlined;
    } else {
      return Icons.visibility_outlined;
    }
  }

  String? _validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }

    return null;
  }

  String? _validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }

    return null;
  }

  void _onEmailAndPasswordFormSubmitted(String email, String password) {
    if (_formKey.currentState!.validate()) {
      widget.onPasswordLogin(email, password);
    }
  }

  Widget _intro() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/images/Icon-192.png", width: 64),
          const SizedBox(height: 16),
          Text(widget.title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 24),
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          OutlinedButton(
            onPressed: widget.onGoogleLogin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/google.svg", width: 18),
                const SizedBox(width: 8),
                const Text("Google で続行"),
              ],
            ),
          ),
          Text(
            'または',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              spacing: 24,
              children: [
                TextFormField(
                  controller: emailFieldController,
                  autofillHints: const [AutofillHints.email],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'メールアドレス',
                  ),
                  validator: _validateEmailField,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                TextFormField(
                  controller: passwordFieldController,
                  autofillHints: const [AutofillHints.password],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'パスワード',
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(_passwordVisibilityIcon()),
                    ),
                  ),
                  obscureText: invisiblePassword,
                  validator: _validatePasswordField,
                  onFieldSubmitted: (value) {
                    _onEmailAndPasswordFormSubmitted(
                      emailFieldController.text,
                      passwordFieldController.text,
                    );
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      _onEmailAndPasswordFormSubmitted(
                        emailFieldController.text,
                        passwordFieldController.text,
                      );
                    },
                    child: const Text('ログイン'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        spacing: 48,
        children: [_intro(), _form()],
      ),
    );
  }
}
