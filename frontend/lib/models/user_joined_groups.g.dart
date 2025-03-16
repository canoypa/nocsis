// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_joined_groups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserJoinedGroup _$UserJoinedGroupFromJson(Map<String, dynamic> json) =>
    _UserJoinedGroup(
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$UserJoinedGroupToJson(_UserJoinedGroup instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'group_name': instance.groupName,
      'user_id': instance.userId,
    };

_UserJoinedGroups _$UserJoinedGroupsFromJson(Map<String, dynamic> json) =>
    _UserJoinedGroups(
      groups:
          (json['groups'] as List<dynamic>)
              .map((e) => UserJoinedGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$UserJoinedGroupsToJson(_UserJoinedGroups instance) =>
    <String, dynamic>{'groups': instance.groups};
