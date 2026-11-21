import 'dart:async';

import 'package:google_identity_services_web/loader.dart' as gis;
import 'package:google_identity_services_web/oauth2.dart';

const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

/// Google ログインに使う OAuth クライアントの ID。プロジェクト ID ごと
const _clientIds = {
  'class-clock-40088': '219141289630-1duqb26tbk7dte61804hjqg64qmhfsc2.apps.googleusercontent.com',
  'nocsis-development': '862064818225-50oucenghkua7qb7hqlpm6vfqp20b6h7.apps.googleusercontent.com',
};

Future<void>? _loading;

/// 選ぶ画面を開く前に読み込んでおく。押してから読み込むと、ポップアップがブロックされる
Future<void> loadGoogleAccountPicker() =>
    _loading ??= gis.loadWebSdk().catchError((Object error) {
      _loading = null;
      throw error;
    });

/// Google アカウントを選んでもらい、そのアカウントのアクセストークンを返す。
/// 閉じられたら null
Future<String?> pickGoogleAccountToken() {
  final clientId = _clientIds[_projectId];
  if (clientId == null) {
    throw StateError('$_projectId の OAuth クライアントがありません');
  }

  final completer = Completer<String?>();
  final client = oauth2.initTokenClient(
    TokenClientConfig(
      client_id: clientId,
      scope: ['openid', 'email'],
      prompt: 'select_account',
      callback: (response) {
        if (completer.isCompleted) return;
        final token = response.access_token;
        if (response.error == 'access_denied') {
          completer.complete(null);
        } else if (token == null) {
          completer.completeError(
            StateError('Google のトークンを得られませんでした: ${response.error}'),
          );
        } else {
          completer.complete(token);
        }
      },
      error_callback: (error) {
        if (completer.isCompleted) return;
        if (error?.type == GoogleIdentityServicesErrorType.popup_closed) {
          completer.complete(null);
        } else {
          completer.completeError(
            StateError('Google のアカウント選択に失敗しました: ${error?.type}'),
          );
        }
      },
    ),
  );
  client.requestAccessToken();

  return completer.future;
}
