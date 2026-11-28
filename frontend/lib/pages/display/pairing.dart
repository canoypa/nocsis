import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http_parser/http_parser.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/themes/display.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 教室ディスプレイにする端末が開く。匿名でサインインしてコードを出し、
/// 管理者が登録するとグループの表示に切り替わる
class DisplayPairingPage extends ConsumerStatefulWidget {
  const DisplayPairingPage({super.key});

  @override
  ConsumerState<DisplayPairingPage> createState() => _DisplayPairingPageState();
}

class _DisplayPairingPageState extends ConsumerState<DisplayPairingPage> {
  static const _pollInterval = Duration(seconds: 3);
  // QR を読んで名前を入れているあいだに切れないよう、期限より前に出し直す
  static const _reissueMargin = Duration(minutes: 2);

  DisplayPairing? _pairing;
  DateTime? _reissueAt;
  Timer? _timer;
  Future<void>? _polling;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    // 画面を作っている最中に遷移しない
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final user = ref.read(firebaseAuthProvider).currentUser;

    // 人のアカウントのまま表示するときは、コンソールの「この端末で表示」を使う
    if (user != null && !user.isAnonymous) {
      if (mounted) context.go('/');
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(displayDeviceKey, true);

    await _startPolling();
  }

  Future<void> _startPolling() async {
    await _poll();
    if (!mounted) return;
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() =>
      _polling ??= _pollOnce().whenComplete(() => _polling = null);

  Future<void> _pollOnce() async {
    if (!mounted || _leaving) return;

    try {
      await _signIn();
      final client = await ref.read(apiClientProvider.future);

      final me = await client.apiV1MeGet();
      final memberships = me.body?.memberships ?? const [];
      if (memberships.isNotEmpty) {
        _timer?.cancel();
        final groupId = memberships.first.group.id;
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('latest_group_id', groupId);
        if (mounted) context.go('/groups/$groupId/classroom');
        return;
      }

      final reissueAt = _reissueAt;
      if (!_leaving &&
          (reissueAt == null || !DateTime.now().isBefore(reissueAt))) {
        final issued = await client.apiV1DisplayPairingsPost();
        final pairing = issued.body;
        if (issued.isSuccessful && pairing != null && mounted) {
          setState(() {
            _pairing = pairing;
            _reissueAt = _localReissueAt(pairing, issued.base.headers['date']);
          });
        }
      }
    } catch (_) {
      // 通信が戻れば次の問い合わせで続きから進む
    }
  }

  /// 登録を解除された端末は、アカウントがサーバで消えている。消えたアカウントの
  /// コードは登録できないので、作り直す
  Future<void> _signIn() async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;

    if (user != null) {
      try {
        await user.reload();
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'user-not-found' && e.code != 'user-disabled') rethrow;
        await auth.signOut();
      }
    }

    // やめた直後に問い合わせが終わると、消したアカウントを作り直してしまう
    if (_leaving) return;
    await auth.signInAnonymously();
  }

  Future<void> _cancel() async {
    final auth = ref.read(firebaseAuthProvider);
    final client = ref.read(apiClientProvider.future);
    setState(() => _leaving = true);
    _timer?.cancel();
    // 途中の問い合わせが後から届くと、消したアカウントにコードを発行し直してしまう
    await _polling;

    int? status;
    try {
      status = (await (await client).apiV1DisplayPairingsDelete()).statusCode;
    } catch (_) {}
    if (!mounted) return;

    // 409 は押したのと同時に登録されたとき。問い合わせを続ければ教室の画面へ進む。
    // 消せなかったときも、コードが残ったまま抜けると登録されてしまうので待ち受けに戻す
    if (status != 204) {
      setState(() => _leaving = false);
      await _startPolling();
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(displayDeviceKey);
    await auth.signOut();
    if (mounted) context.go('/login');
  }

  /// 期限はサーバの時刻なので、端末の時計がずれていても効くよう、残り時間に直して数える
  DateTime _localReissueAt(DisplayPairing pairing, String? serverDate) {
    final serverNow = serverDate == null ? null : _parseHttpDate(serverDate);
    final remaining = pairing.expiresAt.difference(serverNow ?? DateTime.now());

    return DateTime.now().add(remaining - _reissueMargin);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540),
      builder: (context, child) {
        final theme = createDisplayTheme(context, textScale: 1);

        return Theme(
          data: theme,
          child: _PairingView(
            pairing: _pairing,
            onCancel: _leaving ? null : _cancel,
          ),
        );
      },
    );
  }
}

class _PairingView extends StatelessWidget {
  final DisplayPairing? pairing;
  final VoidCallback? onCancel;

  const _PairingView({required this.pairing, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final pairing = this.pairing;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            left: 32.r,
            top: 24.r,
            child: Row(
              children: [
                Icon(Symbols.school, color: colorScheme.primary, size: 24.r),
                SizedBox(width: 8.r),
                Text(
                  'Nocsis',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(40.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QrCode(pairing: pairing),
                    SizedBox(width: 48.r),
                    SizedBox(
                      width: 340.r,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '教室ディスプレイとして登録',
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 12.r),
                          Text(
                            '管理者のスマートフォンで QR コードを読み取るか、コンソールでコードを入力してください。登録されると、予定や天気が表示されます。',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.7,
                            ),
                          ),
                          SizedBox(height: 28.r),
                          Text(
                            'コード',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 8.r),
                          _CodeDigits(code: pairing?.code),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32.r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.r,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12.r,
                  children: [
                    SizedBox.square(
                      dimension: 14.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.r,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '登録を待っています',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton(onPressed: onCancel, child: const Text('登録をやめる')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCode extends StatelessWidget {
  final DisplayPairing? pairing;

  const _QrCode({required this.pairing});

  @override
  Widget build(BuildContext context) {
    final size = 168.r;
    final pairing = this.pairing;

    final data = pairing == null ? null : registerUri(pairing.code).toString();
    final modules = data == null
        ? 0
        : QrValidator.validate(data: data).qrCode?.moduleCount ?? 0;

    // 読み取れるよう、テーマによらず白地に黒。周りは4セル分あける
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: data == null || modules == 0
          ? null
          : QrImageView(
              data: data,
              padding: EdgeInsets.all(size * 4 / (modules + 8)),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
    );
  }
}

/// 管理者のスマートフォンで開く登録画面
Uri registerUri(String code) => Uri(
  scheme: Uri.base.scheme,
  host: Uri.base.host,
  port: Uri.base.hasPort ? Uri.base.port : null,
  path: '/display/register',
  queryParameters: {'code': code},
);

class _CodeDigits extends StatelessWidget {
  final String? code;

  const _CodeDigits({required this.code});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final digits = (code ?? '      ').split('');

    Widget digit(String d) => Container(
      width: 40.r,
      height: 52.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        d,
        style: textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    return Row(
      children: [
        for (final d in digits.take(3)) ...[digit(d), SizedBox(width: 6.r)],
        SizedBox(width: 10.r),
        for (final d in digits.skip(3)) ...[digit(d), SizedBox(width: 6.r)],
      ],
    );
  }
}

DateTime? _parseHttpDate(String value) {
  try {
    return parseHttpDate(value);
  } on FormatException {
    return null;
  }
}

/// 一度でも待ち受けを開いた端末。サインアウトされたら、ログインではなくここへ戻す
const displayDeviceKey = 'display_device';
