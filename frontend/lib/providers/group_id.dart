import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_id.g.dart';

@riverpod
String currentGroupId(_) {
  throw UnimplementedError(
    'currentGroupIdProvider は /groups/:groupId の配下で使用してください。',
  );
}
