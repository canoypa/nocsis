import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class LoginForm extends StatefulWidget {
  /// Material 3 の breakpoint の境目
  static const mediumBreakpoint = 600.0;
  static const expandedBreakpoint = 840.0;

  /// 大きい画面で入力欄やボタンが横に間延びしないよう、中身の幅を抑える
  static const maxWidth = 412.0;

  final String title;
  final String? description;
  final VoidCallback onGoogleLogin;

  /// ログインできたら true を返す。true のときだけパスワードマネージャーに保存を促す。
  final Future<bool> Function(String email, String password) onPasswordLogin;

  const LoginForm({
    super.key,
    this.title = 'ログイン',
    this.description,
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

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    emailFieldController.dispose();
    passwordFieldController.dispose();
    super.dispose();
  }

  Future<void> _onEmailAndPasswordFormSubmitted(
    String email,
    String password,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (await widget.onPasswordLogin(email, password)) {
      TextInput.finishAutofillContext();
    }
  }

  Widget _intro() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < LoginForm.mediumBreakpoint;
    final expanded = width >= LoginForm.expandedBreakpoint;
    final description = widget.description;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: compact ? 40 : 24,
      children: [
        Row(
          spacing: 16,
          children: [
            Image.asset(
              "assets/images/Icon-192.png",
              width: 40,
              excludeFromSemantics: true,
            ),
            Text('Nocsis', style: textTheme.titleMedium),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // M3 の既定の字間は欧文向けで、和文では間延びする
            Text(
              widget.title,
              style:
                  (expanded ? textTheme.displaySmall : textTheme.headlineSmall)
                      ?.copyWith(letterSpacing: 0),
            ),
            if (description != null)
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _orDivider() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'または',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _actions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // G ロゴは色付きの背景に置けないので、tonal ではなく surface の塗りにする
        OutlinedButton(
          onPressed: widget.onGoogleLogin,
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/google/google.png",
                width: 20,
                height: 20,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 10),
              const Text("Google で続行"),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _orDivider(),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: AutofillGroup(
            // 既定の commit だと、失敗した入力や Google でのログインでも保存を促してしまう
            onDisposeAction: AutofillContextAction.cancel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                TextFormField(
                  controller: emailFieldController,
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            _onEmailAndPasswordFormSubmitted(
              emailFieldController.text,
              passwordFieldController.text,
            );
          },
          child: const Text('ログイン'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LoginForm.maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 32,
          children: [_intro(), _actions()],
        ),
      ),
    );
  }
}
