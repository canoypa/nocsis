// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_joined_groups.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserJoinedGroup {

 String get groupId; String get groupName; String get userId;
/// Create a copy of UserJoinedGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserJoinedGroupCopyWith<UserJoinedGroup> get copyWith => _$UserJoinedGroupCopyWithImpl<UserJoinedGroup>(this as UserJoinedGroup, _$identity);

  /// Serializes this UserJoinedGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserJoinedGroup&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,groupName,userId);

@override
String toString() {
  return 'UserJoinedGroup(groupId: $groupId, groupName: $groupName, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $UserJoinedGroupCopyWith<$Res>  {
  factory $UserJoinedGroupCopyWith(UserJoinedGroup value, $Res Function(UserJoinedGroup) _then) = _$UserJoinedGroupCopyWithImpl;
@useResult
$Res call({
 String groupId, String groupName, String userId
});




}
/// @nodoc
class _$UserJoinedGroupCopyWithImpl<$Res>
    implements $UserJoinedGroupCopyWith<$Res> {
  _$UserJoinedGroupCopyWithImpl(this._self, this._then);

  final UserJoinedGroup _self;
  final $Res Function(UserJoinedGroup) _then;

/// Create a copy of UserJoinedGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? groupName = null,Object? userId = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserJoinedGroup implements UserJoinedGroup {
  const _UserJoinedGroup({required this.groupId, required this.groupName, required this.userId});
  factory _UserJoinedGroup.fromJson(Map<String, dynamic> json) => _$UserJoinedGroupFromJson(json);

@override final  String groupId;
@override final  String groupName;
@override final  String userId;

/// Create a copy of UserJoinedGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserJoinedGroupCopyWith<_UserJoinedGroup> get copyWith => __$UserJoinedGroupCopyWithImpl<_UserJoinedGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserJoinedGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserJoinedGroup&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,groupName,userId);

@override
String toString() {
  return 'UserJoinedGroup(groupId: $groupId, groupName: $groupName, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$UserJoinedGroupCopyWith<$Res> implements $UserJoinedGroupCopyWith<$Res> {
  factory _$UserJoinedGroupCopyWith(_UserJoinedGroup value, $Res Function(_UserJoinedGroup) _then) = __$UserJoinedGroupCopyWithImpl;
@override @useResult
$Res call({
 String groupId, String groupName, String userId
});




}
/// @nodoc
class __$UserJoinedGroupCopyWithImpl<$Res>
    implements _$UserJoinedGroupCopyWith<$Res> {
  __$UserJoinedGroupCopyWithImpl(this._self, this._then);

  final _UserJoinedGroup _self;
  final $Res Function(_UserJoinedGroup) _then;

/// Create a copy of UserJoinedGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? groupName = null,Object? userId = null,}) {
  return _then(_UserJoinedGroup(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserJoinedGroups {

 List<UserJoinedGroup> get groups;
/// Create a copy of UserJoinedGroups
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserJoinedGroupsCopyWith<UserJoinedGroups> get copyWith => _$UserJoinedGroupsCopyWithImpl<UserJoinedGroups>(this as UserJoinedGroups, _$identity);

  /// Serializes this UserJoinedGroups to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserJoinedGroups&&const DeepCollectionEquality().equals(other.groups, groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'UserJoinedGroups(groups: $groups)';
}


}

/// @nodoc
abstract mixin class $UserJoinedGroupsCopyWith<$Res>  {
  factory $UserJoinedGroupsCopyWith(UserJoinedGroups value, $Res Function(UserJoinedGroups) _then) = _$UserJoinedGroupsCopyWithImpl;
@useResult
$Res call({
 List<UserJoinedGroup> groups
});




}
/// @nodoc
class _$UserJoinedGroupsCopyWithImpl<$Res>
    implements $UserJoinedGroupsCopyWith<$Res> {
  _$UserJoinedGroupsCopyWithImpl(this._self, this._then);

  final UserJoinedGroups _self;
  final $Res Function(UserJoinedGroups) _then;

/// Create a copy of UserJoinedGroups
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<UserJoinedGroup>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserJoinedGroups implements UserJoinedGroups {
  const _UserJoinedGroups({required final  List<UserJoinedGroup> groups}): _groups = groups;
  factory _UserJoinedGroups.fromJson(Map<String, dynamic> json) => _$UserJoinedGroupsFromJson(json);

 final  List<UserJoinedGroup> _groups;
@override List<UserJoinedGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of UserJoinedGroups
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserJoinedGroupsCopyWith<_UserJoinedGroups> get copyWith => __$UserJoinedGroupsCopyWithImpl<_UserJoinedGroups>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserJoinedGroupsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserJoinedGroups&&const DeepCollectionEquality().equals(other._groups, _groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'UserJoinedGroups(groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$UserJoinedGroupsCopyWith<$Res> implements $UserJoinedGroupsCopyWith<$Res> {
  factory _$UserJoinedGroupsCopyWith(_UserJoinedGroups value, $Res Function(_UserJoinedGroups) _then) = __$UserJoinedGroupsCopyWithImpl;
@override @useResult
$Res call({
 List<UserJoinedGroup> groups
});




}
/// @nodoc
class __$UserJoinedGroupsCopyWithImpl<$Res>
    implements _$UserJoinedGroupsCopyWith<$Res> {
  __$UserJoinedGroupsCopyWithImpl(this._self, this._then);

  final _UserJoinedGroups _self;
  final $Res Function(_UserJoinedGroups) _then;

/// Create a copy of UserJoinedGroups
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,}) {
  return _then(_UserJoinedGroups(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<UserJoinedGroup>,
  ));
}


}

// dart format on
