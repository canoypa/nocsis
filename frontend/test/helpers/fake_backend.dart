import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';

/// パスごとに決めた JSON を返す API クライアント。
/// API クライアントを mocktail で差し替えないのは、JSON をモデルに戻す生成コードが通らなくなるため
Api fakeBackend(Map<String, Object> responses) {
  return Api.create(
    baseUrl: Uri.parse('http://backend.test'),
    httpClient: MockClient((request) async {
      final response = responses[request.url.path];
      return switch (response) {
        null => http.Response('', 404),
        http.Response() => response,
        _ => http.Response(
          jsonEncode(response),
          200,
          headers: {'content-type': 'application/json'},
        ),
      };
    }),
  );
}
