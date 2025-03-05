import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_joined_groups.freezed.dart';
part 'user_joined_groups.g.dart';

@freezed
class UserJoinedGroup with _$UserJoinedGroup {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserJoinedGroup({
    required String groupId,
    required String groupName,
    required String userId,
  }) = _UserJoinedGroup;

  factory UserJoinedGroup.fromJson(Map<String, dynamic> json) =>
      _$UserJoinedGroupFromJson(json);
}

@freezed
class UserJoinedGroups with _$UserJoinedGroups {
  const factory UserJoinedGroups({required List<UserJoinedGroup> groups}) =
      _UserJoinedGroups;

  factory UserJoinedGroups.fromJson(Map<String, dynamic> json) =>
      _$UserJoinedGroupsFromJson(json);
}
