import 'dart:math';

import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'me.g.dart';

/// 既定のリトライは 10 回で諦める。教室の画面は人が見ていないまま放置されるので、
/// 通信が戻ればそのまま開けるよう、間隔を 1 分まで延ばしながら取り直し続ける
Duration? _retryForever(int retryCount, Object error) =>
    Duration(seconds: min(60, pow(2, min(retryCount, 6)).toInt()));

@riverpod
String? currentUid(Ref ref) => ref.watch(authProvider).value?.uid;

/// uid ごとに分けるのは、別のアカウントに替わったときに前のアカウントの値を
/// 前の値として持ち越さないため
@Riverpod(retry: _retryForever)
Future<Me> me(Ref ref, String uid) async {
  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1MeGet();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Me fetch failed: ${response.statusCode}');
  }
}

/// 画面の出し分けにだけ使う。操作の可否はサーバが毎回判定する
@Riverpod(retry: _retryForever)
Future<Set<Permission>> groupPermissions(
  Ref ref,
  String uid,
  String groupId,
) async {
  final me = await ref.watch(meProvider(uid).future);

  return me.memberships
      .where((membership) => membership.group.id == groupId)
      .expand((membership) => membership.permissions)
      .toSet();
}

/// メニューやボタンの出し分け用。取れるまでは何も持っていない扱いにする
Set<Permission> watchGrantedPermissions(WidgetRef ref, String groupId) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const {};

  return ref.watch(groupPermissionsProvider(uid, groupId)).value ?? const {};
}
