import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'me.g.dart';

@riverpod
Future<Me> me(Ref ref) async {
  // 別のアカウントでログインし直したら、前のアカウントの権限を使わない
  ref.watch(authProvider);

  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1MeGet();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Me fetch failed: ${response.statusCode}');
  }
}

/// 画面の出し分けにだけ使う。操作の可否はサーバが毎回判定する
@riverpod
Future<Set<Permission>> groupPermissions(Ref ref, String groupId) async {
  final me = await ref.watch(meProvider.future);

  return me.memberships
      .where((membership) => membership.group.id == groupId)
      .expand((membership) => membership.permissions)
      .toSet();
}
