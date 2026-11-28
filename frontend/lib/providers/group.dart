import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group.g.dart';

@riverpod
Future<Group> group(Ref ref, String groupId) async {
  final client = await ref.watch(apiClientProvider.future);
  final response = await client.apiV1GroupsIdGet(id: groupId);

  if (response.isSuccessful && response.body != null) {
    return response.body!;
  } else {
    throw Exception('Group fetch failed: ${response.statusCode}');
  }
}
