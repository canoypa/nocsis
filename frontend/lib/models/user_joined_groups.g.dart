// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_joined_groups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserJoinedGroupImpl _$$UserJoinedGroupImplFromJson(
  Map<String, dynamic> json,
) => _$UserJoinedGroupImpl(
  groupId: json['group_id'] as String,
  groupName: json['group_name'] as String,
  userId: json['user_id'] as String,
);

Map<String, dynamic> _$$UserJoinedGroupImplToJson(
  _$UserJoinedGroupImpl instance,
) => <String, dynamic>{
  'group_id': instance.groupId,
  'group_name': instance.groupName,
  'user_id': instance.userId,
};

_$UserJoinedGroupsImpl _$$UserJoinedGroupsImplFromJson(
  Map<String, dynamic> json,
) => _$UserJoinedGroupsImpl(
  groups:
      (json['groups'] as List<dynamic>)
          .map((e) => UserJoinedGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$UserJoinedGroupsImplToJson(
  _$UserJoinedGroupsImpl instance,
) => <String, dynamic>{'groups': instance.groups};
