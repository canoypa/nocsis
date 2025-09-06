import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

const String _baseUrl = kDebugMode
    ? 'http://localhost:8080'
    : 'https://nocsis.app/api';

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
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final token = await user.getIdToken();
  if (token == null) {
    throw Exception('Failed to get auth token');
  }

  return BearerAuthInterceptor(token);
}

@riverpod
Future<Api> apiClient(Ref ref) async {
  final interceptor = await ref.watch(firebaseAuthInterceptorProvider.future);

  return Api.create(baseUrl: Uri.parse(_baseUrl), interceptors: [interceptor]);
}
