import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nocsis/core/client_commit.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

// E2E で kDebugMode に頼らない。デバッグビルドは本番と別のコンパイラで作られるため、
// 本番と同じ wasm のビルドで backend を指せるよう --dart-define で上書きできるようにする。
const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

/// backend の URL。エラーの報告など、認証の要らない送り先でも使う
final String apiBaseUrl = _apiBaseUrlOverride.isNotEmpty
    ? _apiBaseUrlOverride
    : kDebugMode
    ? 'http://localhost:8080'
    : Uri.base.origin;

// 作るときに取ったトークンを持ち続けない。持つとトークンが替わるたびに API クライアントを
// 作り直すことになり、それを watch している一覧が読み直される
class FirebaseAuthInterceptor implements Interceptor {
  final FirebaseAuth auth;

  FirebaseAuthInterceptor(this.auth);

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get auth token');
    }

    final request = chain.request.copyWith(
      headers: {...chain.request.headers, 'Authorization': 'Bearer $token'},
    );
    return chain.proceed(request);
  }
}

@riverpod
Future<Api> apiClient(Ref ref) async {
  final auth = ref.watch(firebaseAuthProvider);

  return Api.create(
    baseUrl: Uri.parse(apiBaseUrl),
    interceptors: [
      FirebaseAuthInterceptor(auth),
      clientCommitInterceptor(buildCommit),
    ],
  );
}
