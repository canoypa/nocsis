import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'me.g.dart';

@riverpod
String? currentUid(Ref ref) => ref.watch(authProvider).value?.uid;

// 既定のリトライのあいだ .future は失敗を返さず、router の redirect が画面遷移ごと
// 待たされる。失敗はすぐ返し、取り直しは redirect が次の遷移で行う
Duration? _noRetry(int retryCount, Object error) => null;

/// uid ごとに分けるのは、別のアカウントに替わったときに前のアカウントの値を
/// 前の値として持ち越さないため
@Riverpod(retry: _noRetry)
Future<Me> me(Ref ref, String uid) async {
  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1MeGet();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Me fetch failed: ${response.statusCode}');
  }
}

Set<Permission> permissionsIn(Me me, String groupId) => me.memberships
    .where((membership) => membership.group.id == groupId)
    .expand((membership) => membership.permissions)
    .toSet();

/// 画面の出し分けにだけ使う。操作の可否はサーバが毎回判定する
@riverpod
Future<Set<Permission>> groupPermissions(
  Ref ref,
  String uid,
  String groupId,
) async => permissionsIn(await ref.watch(meProvider(uid).future), groupId);

/// メニューやボタンの出し分け用。取れるまでは何も持っていない扱いにする
Set<Permission> watchGrantedPermissions(WidgetRef ref, String groupId) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const {};

  return ref.watch(groupPermissionsProvider(uid, groupId)).value ?? const {};
}
