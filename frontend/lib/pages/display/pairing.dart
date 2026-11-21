import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

  DisplayPairing? _pairing;
  Timer? _timer;
  bool _polling = false;

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
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;

    // 人のアカウントのまま表示するときは、コンソールの「この端末で表示」を使う
    if (user != null && !user.isAnonymous) {
      if (mounted) context.go('/');
      return;
    }
    if (user == null) {
      await auth.signInAnonymously();
    }

    await _poll();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (_polling || !mounted) return;
    _polling = true;

    try {
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

      final pairing = _pairing;
      if (pairing == null || !pairing.expiresAt.isAfter(DateTime.now())) {
        final issued = await client.apiV1DisplayPairingsPost();
        if (issued.isSuccessful && mounted) {
          setState(() => _pairing = issued.body);
        }
      }
    } catch (_) {
      // 通信が戻れば次の問い合わせで続きから進む
    } finally {
      _polling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540),
      builder: (context, child) {
        final theme = createDisplayTheme(context, textScale: 1);

        return Theme(
          data: theme,
          child: _PairingView(pairing: _pairing),
        );
      },
    );
  }
}

class _PairingView extends StatelessWidget {
  final DisplayPairing? pairing;

  const _PairingView({required this.pairing});

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
              children: [
                SizedBox.square(
                  dimension: 14.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.r),
                Text(
                  '登録を待っています',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
