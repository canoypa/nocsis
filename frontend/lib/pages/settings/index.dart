import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/components/login_form.dart';
import 'package:nocsis/core/google_account_token.dart';
import 'package:nocsis/custom_icons.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/providers/user.dart';

/// backend が再認証を求めるまでの時間。backend より少し短くして、選んだあとに弾かれにくくする
const _recentLogin = Duration(minutes: 4);

/// 最後にログイン (再認証を含む) した時刻
final _authTimeProvider = StreamProvider.autoDispose<DateTime?>(
  (ref) => ref
      .watch(firebaseAuthProvider)
      .idTokenChanges()
      .asyncMap((user) async => (await user?.getIdTokenResult())?.authTime),
);

enum _ReplaceResult { replaced, cancelled, requiresRecentLogin }

enum _GoogleSwapState {
  idle,

  /// 再ログインかアカウントの選択の途中
  choosing,

  /// 選んだアカウントへの差し替えを待っている
  replacing,
}

final _googleSwapStateProvider =
    NotifierProvider<_GoogleSwapStateNotifier, _GoogleSwapState>(
      _GoogleSwapStateNotifier.new,
    );

class _GoogleSwapStateNotifier extends Notifier<_GoogleSwapState> {
  @override
  _GoogleSwapState build() => _GoogleSwapState.idle;

  void set(_GoogleSwapState value) => state = value;
}

bool _loggedInRecently(DateTime? authTime) =>
    authTime != null && DateTime.now().difference(authTime) < _recentLogin;

/// 選んだアカウントに連携を差し替える
Future<_ReplaceResult> _submitGoogleAccount(
  ProviderContainer container,
  ScaffoldMessengerState messenger,
  String accessToken,
) async {
  final swapState = container.read(_googleSwapStateProvider.notifier);
  swapState.set(_GoogleSwapState.replacing);
  try {
    final client = await container.read(apiClientProvider.future);
    final response = await client.apiV1MeGoogleAccountPut(
      body: GoogleAccountPutJson(accessToken: accessToken),
    );

    if (response.statusCode == 403 &&
        response.bodyString.contains('requires-recent-login')) {
      return _ReplaceResult.requiresRecentLogin;
    }
    if (response.statusCode == 409 &&
        response.bodyString.contains('linked-to-another-user')) {
      messenger.showSnackBar(
        const SnackBar(content: Text('この Google アカウントはすでに別のユーザーと連携されています。')),
      );
      return _ReplaceResult.cancelled;
    }
    if (!response.isSuccessful) {
      messenger.showSnackBar(const SnackBar(content: Text('連携を変更できませんでした。')));
      throw Exception('Google account replace failed: ${response.statusCode}');
    }

    await container.read(authenticatedUserProvider).reload();
    container.invalidate(currentUserProvider);
    messenger.showSnackBar(const SnackBar(content: Text('Google の連携を変更しました。')));
    return _ReplaceResult.replaced;
  } finally {
    swapState.set(_GoogleSwapState.choosing);
  }
}

final _googleAccountPickerLoadedProvider = FutureProvider.autoDispose(
  (ref) => loadGoogleAccountPicker(),
);

class SettingsTopPage extends ConsumerWidget {
  const SettingsTopPage({super.key});

  Future<void> _onReplaceGoogleAccountPressed(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final swapState = ref.read(_googleSwapStateProvider.notifier);
    swapState.set(_GoogleSwapState.choosing);

    try {
      // ポップアップは押した直後にしか開けないので、アカウント選択より前に await しない
      String? accessToken;
      if (_loggedInRecently(ref.read(_authTimeProvider).value)) {
        accessToken = await pickGoogleAccountToken();
        if (accessToken == null) return;
      }

      while (true) {
        if (accessToken == null) {
          if (!context.mounted) return;
          accessToken = await showDialog<String>(
            context: context,
            builder: (_) => const _ReplaceGoogleAccountDialog(),
          );
          if (accessToken == null) return;
        }

        final result = await _submitGoogleAccount(
          container,
          messenger,
          accessToken,
        );
        // 選んでいる間にログインから時間がたったときは、再ログインからやり直す
        if (result != _ReplaceResult.requiresRecentLogin) return;
        accessToken = null;
      }
    } finally {
      swapState.set(_GoogleSwapState.idle);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authenticatedUserProvider);

    final googleEmail = user.providerData
        .firstWhereOrNull((e) => e.providerId == GoogleAuthProvider.PROVIDER_ID)
        ?.email;

    final pickerLoaded = ref.watch(_googleAccountPickerLoadedProvider).hasValue;
    final swapState = ref.watch(_googleSwapStateProvider);
    final replacing = swapState == _GoogleSwapState.replacing;
    ref.watch(_authTimeProvider);
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '設定',
              style: compact
                  ? Theme.of(context).textTheme.headlineLarge
                  : Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 48),
            Text(
              'アカウント',
              style: compact
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: _ActionRow(
                compact: compact,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メールアドレス',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(user.email ?? ''),
                  ],
                ),
                action: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ChangeEmailDialog(
                          onSubmit: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                  child: const Text('変更する'),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'ログイン',
              style: compact
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ActionRow(
                      compact: compact,
                      content: const Row(
                        children: [
                          Icon(Icons.password),
                          SizedBox(width: 8),
                          Text('パスワード'),
                        ],
                      ),
                      action: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ChangePasswordDialog(
                                onSubmit: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                        child:
                            user.providerData.any(
                              (e) => e.providerId == 'password',
                            )
                            ? const Text('変更する')
                            : const Text('設定する'),
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ActionRow(
                      compact: compact,
                      content: Row(
                        children: [
                          const Icon(CustomIcons.google),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Google'),
                                if (replacing)
                                  // メールアドレスの行と同じ高さ
                                  Container(
                                    width: 200,
                                    height: 16,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                else if (googleEmail != null)
                                  Text(
                                    googleEmail,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      action: TextButton(
                        onPressed:
                            pickerLoaded && swapState == _GoogleSwapState.idle
                            ? () => _onReplaceGoogleAccountPressed(context, ref)
                            : null,
                        child: const Text("別アカウントと連携する"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 狭い幅ではボタンを次の行に回す
class _ActionRow extends StatelessWidget {
  final bool compact;
  final Widget content;
  final Widget action;

  const _ActionRow({
    required this.compact,
    required this.content,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [content, const SizedBox(height: 8), action],
      );
    }
    return Row(
      children: [
        Expanded(child: content),
        const SizedBox(width: 16),
        action,
      ],
    );
  }
}

class ChangeEmailDialog extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;

  const ChangeEmailDialog({super.key, required this.onSubmit});

  @override
  ChangeEmailDialogState createState() => ChangeEmailDialogState();
}

class ChangeEmailDialogState extends ConsumerState<ChangeEmailDialog> {
  bool reauthenticating = false;

  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _changeEmail(User currentUser) async {
    try {
      await currentUser.verifyBeforeUpdateEmail(emailController.text);
    } on FirebaseAuthException catch (error) {
      if (!mounted) rethrow;
      final requiresRecentLogin = error.code == 'requires-recent-login';
      setState(() {
        reauthenticating = requiresRecentLogin;
      });
      if (!requiresRecentLogin) {
        rethrow;
      }
      return;
    }

    if (!mounted) return;
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return _ReauthenticationDialog(
      title: 'メールアドレスを変更する',
      currentUser: user,
      reauthenticating: reauthenticating,
      onReauthenticated: () => _changeEmail(user),
      form: _changeEmailForm(user),
    );
  }

  Widget _changeEmailForm(User currentUser) {
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
          Center(
            child: Text(
              'メールアドレスを変更する',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            '1. 新しいメールアドレスを入力して、「確認する」を押してください。\n2. 入力したメールアドレス宛に確認のメールが届きます。メールに含まれるリンクを開いて、メールアドレスの変更を完了してください。',
          ),
          const SizedBox(height: 8),
          const Text(
            '※ 連携している Google アカウントは変更されません。\n※ 「新しいメールアドレスでログインできるようになりました」と表示されますが、現在 Google アカウント以外でログインする方法はないため、この内容は無視してください。',
          ),
          const SizedBox(height: 48),
          TextField(
            autofocus: true,
            controller: emailController,
            decoration: const InputDecoration(
              labelText: '新しいメールアドレス',
              hintText: 'yourname@gmail.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _changeEmail(currentUser),
              child: const Text('確認する'),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;

  const ChangePasswordDialog({super.key, required this.onSubmit});

  @override
  ChangePasswordDialogState createState() => ChangePasswordDialogState();
}

class ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  bool reauthenticating = false;

  final TextEditingController passwordController = TextEditingController();
  bool invisiblePassword = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _changePasswordVisibilityCallback() {
    setState(() {
      invisiblePassword = invisiblePassword ? false : true;
    });
  }

  IconData _passwordVisibilityIcon() {
    return invisiblePassword
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
  }

  Future<void> _changePassword(User currentUser) async {
    if (passwordController.text.isEmpty) {
      setState(() {
        reauthenticating = false;
        hasError = true;
        errorMessage = 'パスワードを入力してください。';
      });
      return;
    }

    try {
      await currentUser.updatePassword(passwordController.text);
    } on FirebaseAuthException catch (error) {
      if (!mounted) rethrow;
      switch (error.code) {
        case 'requires-recent-login':
          setState(() {
            reauthenticating = true;
          });
        case 'weak-password':
          setState(() {
            reauthenticating = false;
            hasError = true;
            errorMessage = 'パスワードが弱すぎます。';
          });
        default:
          setState(() {
            reauthenticating = false;
            hasError = true;
          });
          rethrow;
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() {
          reauthenticating = false;
          hasError = true;
        });
      }
      rethrow;
    }

    if (!mounted) return;
    setState(() {
      hasError = false;
    });

    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return _ReauthenticationDialog(
      title: 'パスワードを設定する',
      currentUser: user,
      reauthenticating: reauthenticating,
      onReauthenticated: () => _changePassword(user),
      form: _changePasswordForm(user),
    );
  }

  Widget _changePasswordForm(User currentUser) {
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
          Center(
            child: Text(
              'パスワードを設定する',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            autofocus: true,
            controller: passwordController,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: '新しいパスワード',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _changePasswordVisibilityCallback,
                icon: Icon(_passwordVisibilityIcon()),
              ),
              errorText: hasError ? errorMessage : null,
            ),
            obscureText: invisiblePassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _changePassword(currentUser),
              child: const Text('設定する'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 再認証してから、連携する Google アカウントを選んでもらう
class _ReplaceGoogleAccountDialog extends ConsumerStatefulWidget {
  const _ReplaceGoogleAccountDialog();

  @override
  ConsumerState<_ReplaceGoogleAccountDialog> createState() =>
      _ReplaceGoogleAccountDialogState();
}

class _ReplaceGoogleAccountDialogState
    extends ConsumerState<_ReplaceGoogleAccountDialog> {
  bool reauthenticating = true;

  Future<void> _onReauthenticated(User user) async {
    // API クライアントは作ったときのトークンを使い続けるので、再認証した時刻の入ったトークンで作り直す
    await user.getIdToken(true);
    ref.invalidate(firebaseAuthInterceptorProvider);
    if (!mounted) return;
    setState(() => reauthenticating = false);
  }

  /// 選んだアカウントのアクセストークンを返して閉じる
  Future<void> _pick() async {
    if (!_loggedInRecently(ref.read(_authTimeProvider).value)) {
      setState(() => reauthenticating = true);
      return;
    }
    final accessToken = await pickGoogleAccountToken();
    if (accessToken == null || !mounted) return;
    Navigator.of(context).pop(accessToken);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authenticatedUserProvider);

    return _ReauthenticationDialog(
      title: '別アカウントと連携する',
      currentUser: user,
      reauthenticating: reauthenticating,
      onReauthenticated: () => _onReauthenticated(user),
      form: Container(
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
            Center(
              child: Text(
                '別アカウントと連携する',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 48),
            const Text('連携する Google アカウントを選んでください。'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _pick,
                child: const Text('アカウントを選ぶ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 変更が再認証を求められたときだけ、変更のフォームを再認証の LoginForm に切り替える。
class _ReauthenticationDialog extends StatelessWidget {
  final String title;
  final User currentUser;
  final bool reauthenticating;
  final Future<void> Function() onReauthenticated;
  final Widget form;

  const _ReauthenticationDialog({
    required this.title,
    required this.currentUser,
    required this.reauthenticating,
    required this.onReauthenticated,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: reauthenticating ? _loginForm(context) : form,
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    return _ReauthenticationCard(
      child: LoginForm(
        title: title,
        description: '続けるには、もう一度ログインしてください。',
        onGoogleLogin: () async {
          final googleEmail = currentUser.providerData
              .firstWhereOrNull(
                (e) => e.providerId == GoogleAuthProvider.PROVIDER_ID,
              )
              ?.email;
          final provider = GoogleAuthProvider();
          if (googleEmail != null) {
            provider.setCustomParameters({'login_hint': googleEmail});
          }
          try {
            await currentUser.reauthenticateWithPopup(provider);
          } on FirebaseAuthException catch (e) {
            if (e.code != 'user-mismatch' || !context.mounted) rethrow;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('今ログインしている Google アカウントを選んでください。')),
            );
            return;
          }
          await onReauthenticated();
        },
        onPasswordLogin: (email, password) async {
          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );
          await currentUser.reauthenticateWithCredential(credential);
          await onReauthenticated();
          return true;
        },
      ),
    );
  }
}

/// 再認証の LoginForm にダイアログの面を付ける。
/// 狭い画面ではキーボードで高さが足りなくなるのでスクロールできるようにする。
class _ReauthenticationCard extends StatelessWidget {
  final Widget child;

  const _ReauthenticationCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}
