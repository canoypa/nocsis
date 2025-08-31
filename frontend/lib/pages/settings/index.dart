import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/components/login_form.dart';
import 'package:nocsis/custom_icons.dart';
import 'package:nocsis/providers/user.dart';

class SettingsTopPage extends ConsumerWidget {
  const SettingsTopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const SizedBox();
    }

    final googleEmail = user.providerData
        .firstWhereOrNull((e) => e.providerId == GoogleAuthProvider.PROVIDER_ID)
        ?.email;

    final hasNonGoogleLoginProvider = user.providerData.any(
      (e) => e.providerId != GoogleAuthProvider.PROVIDER_ID,
    );

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('設定', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 48),
            Text('アカウント', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Column(
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
                const Spacer(),
                OutlinedButton(
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
              ],
            ),
            const SizedBox(height: 48),
            Text('ログイン', style: Theme.of(context).textTheme.headlineMedium),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.password),
                        const SizedBox(width: 8),
                        const Text('パスワード'),
                        const Spacer(),
                        TextButton(
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
                      ],
                    ),
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(CustomIcons.google),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Google'),
                                if (googleEmail != null)
                                  Text(
                                    googleEmail,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: hasNonGoogleLoginProvider
                              ? () async {
                                  try {
                                    await user.unlink(
                                      GoogleAuthProvider.PROVIDER_ID,
                                    );
                                  } catch (e) {
                                    if (e is FirebaseAuthException &&
                                        e.code == 'no-such-provider') {
                                      // noop
                                    } else {
                                      rethrow;
                                    }
                                  }

                                  try {
                                    await user.linkWithPopup(
                                      GoogleAuthProvider(),
                                    );
                                  } catch (e) {
                                    if (e is FirebaseAuthException &&
                                        e.code == 'credential-already-in-use') {
                                      final currentEmail = user.providerData
                                          .firstWhere(
                                            (e) =>
                                                e.providerId ==
                                                GoogleAuthProvider.PROVIDER_ID,
                                          )
                                          .email;
                                      final sameAccount =
                                          e.email == currentEmail;

                                      if (!sameAccount) {
                                        ScaffoldMessenger.of(
                                          // ignore: use_build_context_synchronously
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'この Google アカウントはすでに別のユーザーと連携されています。',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      rethrow;
                                    }
                                  }
                                }
                              : null,
                          child: Tooltip(
                            message: !hasNonGoogleLoginProvider
                                ? '別アカウントと連携するには、初めにパスワードを設定してください。'
                                : '',
                            child: const Text("別アカウントと連携する"),
                          ),
                        ),
                      ],
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

class ChangeEmailDialog extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;

  const ChangeEmailDialog({super.key, required this.onSubmit});

  @override
  ChangeEmailDialogState createState() => ChangeEmailDialogState();
}

class ChangeEmailDialogState extends ConsumerState<ChangeEmailDialog> {
  bool reAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

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
        child: !reAuthenticated ? _loginForm(user) : _changeEmailForm(user),
      ),
    );
  }

  Widget _loginForm(User currentUser) {
    return LoginForm(
      title: "メールアドレスを変更する",
      description: '始めに、現在のアカウントで再認証が必要です。',
      onGoogleLogin: () async {
        await currentUser.reauthenticateWithPopup(GoogleAuthProvider());

        setState(() {
          reAuthenticated = true;
        });
      },
      onPasswordLogin: (email, password) async {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);

        setState(() {
          reAuthenticated = true;
        });
      },
    );
  }

  Widget _changeEmailForm(User currentUser) {
    final TextEditingController emailController = TextEditingController();

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
              onPressed: () async {
                await currentUser.verifyBeforeUpdateEmail(emailController.text);

                widget.onSubmit();
              },
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
  bool reAuthenticated = false;

  final TextEditingController passwordController = TextEditingController();
  bool invisiblePassword = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const SizedBox.shrink();
    }

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
        child: !reAuthenticated ? _loginForm(user) : _changeEmailForm(user),
      ),
    );
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

  Widget _loginForm(User currentUser) {
    return LoginForm(
      title: "パスワードを設定する",
      description: '始めに、現在のアカウントで再認証が必要です。',
      onGoogleLogin: () async {
        await currentUser.reauthenticateWithPopup(GoogleAuthProvider());

        setState(() {
          reAuthenticated = true;
        });
      },
      onPasswordLogin: (email, password) async {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);

        setState(() {
          reAuthenticated = true;
        });
      },
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
              'パスワードを設定する',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            autofocus: true,
            controller: passwordController,
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
              onPressed: () async {
                try {
                  if (passwordController.text.isEmpty) {
                    setState(() {
                      hasError = true;
                      errorMessage = 'パスワードを入力してください。';
                    });
                    return;
                  }

                  await currentUser.updatePassword(passwordController.text);

                  setState(() {
                    hasError = false;
                  });

                  widget.onSubmit();
                } catch (error) {
                  setState(() {
                    hasError = true;
                  });

                  if (error is FirebaseAuthException &&
                      error.code == 'weak-password') {
                    setState(() {
                      errorMessage = 'パスワードが弱すぎます。';
                    });
                  } else {
                    rethrow;
                  }
                }
              },
              child: const Text('設定する'),
            ),
          ),
        ],
      ),
    );
  }
}
