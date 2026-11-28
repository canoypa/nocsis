import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/api_client.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this.token);

  final String token;

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => token;
}

class _FakeAuth extends Fake implements FirebaseAuth {
  String? token;

  @override
  User? get currentUser => switch (token) {
    final token? => _FakeUser(token),
    null => null,
  };
}

void main() {
  group('FirebaseAuthInterceptor', () {
    late _FakeAuth auth;
    late List<String?> authorizations;
    late Api api;

    setUp(() {
      auth = _FakeAuth();
      authorizations = [];
      api = Api.create(
        baseUrl: Uri.parse('http://backend.test'),
        httpClient: MockClient((request) async {
          authorizations.add(request.headers['Authorization']);
          return http.Response('', 404);
        }),
        interceptors: [FirebaseAuthInterceptor(auth)],
      );
    });

    test('呼び出すたびに、その時のユーザーのトークンを付ける', () async {
      auth.token = 'token-1';
      await api.apiV1MeGet();
      auth.token = 'token-2';
      await api.apiV1MeGet();

      expect(authorizations, ['Bearer token-1', 'Bearer token-2']);
    });

    test('ログインしていないときは送らない', () async {
      await expectLater(api.apiV1MeGet(), throwsException);

      expect(authorizations, isEmpty);
    });
  });
}
