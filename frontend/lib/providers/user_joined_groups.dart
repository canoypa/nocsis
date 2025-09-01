import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/user_joined_groups.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_joined_groups.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v4-groups-user_joined_groups-get");

@riverpod
Future<UserJoinedGroups> userJoinedGroups(Ref ref) async {
  // 新しいAPIの呼び出しテスト
  try {
    final client = await ref.read(apiClientProvider.future);
    unawaited(
      client
          .apiV1UsersMeGroupsGet()
          .then((_) => print('[UserJoinedGroups] New API test success'))
          .catchError(
            (error) => print('[UserJoinedGroups] New API test error: $error'),
          ),
    );
  } catch (error) {
    print('[UserJoinedGroups] New API client initialization failed');
  }

  final res = await fn.call();

  if (res.data == null) {
    throw Exception("No data");
  }

  return UserJoinedGroups.fromJson(res.data);
}
