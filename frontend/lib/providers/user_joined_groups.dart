import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/models/user_joined_groups.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_joined_groups.g.dart';

final fn = FirebaseFunctions.instanceFor(
  region: "asia-northeast1",
).httpsCallable("v3-classes-get");

@riverpod
Future<UserJoinedGroups> userJoinedGroups(Ref ref) async {
  final res = await fn.call();

  if (res.data == null) {
    throw Exception("No data");
  }

  print(res.data);

  return UserJoinedGroups.fromJson(res.data);
}
