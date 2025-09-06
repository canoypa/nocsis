import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_joined_groups.g.dart';

@riverpod
Future<UserJoinedGroups> userJoinedGroups(Ref ref) async {
  final client = await ref.read(apiClientProvider.future);
  final response = await client.apiV1UsersMeGroupsGet();

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('User joined groups fetch failed: ${response.statusCode}');
  }
}
