import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:nocsis/core/client_commit.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/user.dart';
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

class BearerAuthInterceptor implements Interceptor {
  final String token;

  BearerAuthInterceptor(this.token);

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request.copyWith(
      headers: {...chain.request.headers, 'Authorization': 'Bearer $token'},
    );
    return chain.proceed(request);
  }
}

@riverpod
Future<BearerAuthInterceptor> firebaseAuthInterceptor(Ref ref) async {
  final user = ref.watch(authenticatedUserProvider);

  final token = await user.getIdToken();
  if (token == null) {
    throw Exception('Failed to get auth token');
  }

  return BearerAuthInterceptor(token);
}

@riverpod
Future<Api> apiClient(Ref ref) async {
  final interceptor = await ref.watch(firebaseAuthInterceptorProvider.future);

  return Api.create(
    baseUrl: Uri.parse(apiBaseUrl),
    interceptors: [interceptor, clientCommitInterceptor(buildCommit)],
  );
}
