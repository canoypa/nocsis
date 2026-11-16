import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// ビルド時に埋め込まれた、この画面の版。`flutter run` など、CI 以外のビルドでは空。
const builtVersion = String.fromEnvironment('BUILD_NUMBER');

/// Hosting に置かれた `version.json` から、いまデプロイされている版を読む。
///
/// 読めないときは null を返す。オフラインや一時的な失敗でリロードしないため。
Future<String?> fetchDeployedVersion(http.Client client, Uri base) async {
  // Hosting は静的ファイルをブラウザに1時間キャッシュさせるので、URL ごと変える
  final uri = base.resolve(
    '/version.json?t=${DateTime.now().millisecondsSinceEpoch}',
  );

  try {
    final response = await client.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    final buildNumber = json is Map<String, dynamic>
        ? json['build_number']
        : null;

    return buildNumber is String && buildNumber.isNotEmpty ? buildNumber : null;
  } on Exception {
    return null;
  }
}

/// デプロイされている版を定期的に確かめ、自分と違えば [reload] を呼ぶ。
class NewVersionWatcher {
  NewVersionWatcher({
    required this.current,
    required this.fetchDeployed,
    required this.reload,
    this.canReload = _always,
    this.interval = const Duration(minutes: 5),
  });

  final String current;
  final Future<String?> Function() fetchDeployed;
  final void Function() reload;

  /// 今リロードしてよいか。だめなら次の確認に回す
  final bool Function() canReload;
  final Duration interval;

  Timer? _timer;

  void start() {
    // 版が埋め込まれていないビルドでは、何と比べても違って見えるので見張らない
    if (current.isEmpty) {
      return;
    }

    _timer ??= Timer.periodic(interval, (_) => check());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> check() async {
    final deployed = await fetchDeployed();

    if (_timer != null &&
        deployed != null &&
        deployed != current &&
        canReload()) {
      stop();
      reload();
    }
  }
}

bool _always() => true;
