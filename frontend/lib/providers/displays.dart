import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'displays.g.dart';

@riverpod
Future<List<Display>> displays(Ref ref, String groupId) async {
  final client = await ref.watch(apiClientProvider.future);
  final response = await client.apiV1GroupsGroupIdDisplaysGet(groupId: groupId);

  if (response.isSuccessful && response.body != null) {
    return response.body!.items;
  } else {
    throw Exception('Displays fetch failed: ${response.statusCode}');
  }
}
