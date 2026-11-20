import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginForm extends StatefulWidget {
  static const _defaultFormTitle = 'Nocsis';
  static const _defaultFormDescription = 'ログインして続ける';

  /// Material 3 の breakpoint の境目
  static const mediumBreakpoint = 600.0;
  static const expandedBreakpoint = 840.0;

  /// 大きい画面で入力欄やボタンが横に間延びしないよう、ペインの中身の幅を抑える
  static const paneMaxWidth = 412.0;

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
  /// 入力欄と高さを揃える (M3 Expressive のボタン M サイズ)
  static const _buttonSize = Size.fromHeight(56);

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

  ButtonStyle _buttonStyle(TextTheme textTheme) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(_buttonSize),
      textStyle: WidgetStatePropertyAll(
        textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _intro({required bool centered}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Image.asset("assets/images/Icon-192.png", width: 72),
        const SizedBox(height: 24),
        // M3 の既定の字間は欧文向けで、和文では間延びする
        Text(
          widget.title,
          textAlign: textAlign,
          style: textTheme.headlineMedium?.copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          textAlign: textAlign,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0,
          ),
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.tonal(
          onPressed: widget.onGoogleLogin,
          style: _buttonStyle(textTheme),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/images/google.svg", width: 20),
              const SizedBox(width: 12),
              const Text("Google で続行"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _orDivider(),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
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
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: _buttonStyle(textTheme),
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
    if (MediaQuery.sizeOf(context).width < LoginForm.expandedBreakpoint) {
      return _pane(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _intro(centered: true),
            const SizedBox(height: 48),
            _actions(),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 24,
      children: [
        Expanded(child: _pane(_intro(centered: false))),
        Expanded(child: _pane(_actions())),
      ],
    );
  }

  Widget _pane(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LoginForm.paneMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
