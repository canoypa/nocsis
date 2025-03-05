// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_joined_groups.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserJoinedGroup _$UserJoinedGroupFromJson(Map<String, dynamic> json) {
  return _UserJoinedGroup.fromJson(json);
}

/// @nodoc
mixin _$UserJoinedGroup {
  String get groupId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this UserJoinedGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserJoinedGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserJoinedGroupCopyWith<UserJoinedGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserJoinedGroupCopyWith<$Res> {
  factory $UserJoinedGroupCopyWith(
    UserJoinedGroup value,
    $Res Function(UserJoinedGroup) then,
  ) = _$UserJoinedGroupCopyWithImpl<$Res, UserJoinedGroup>;
  @useResult
  $Res call({String groupId, String groupName, String userId});
}

/// @nodoc
class _$UserJoinedGroupCopyWithImpl<$Res, $Val extends UserJoinedGroup>
    implements $UserJoinedGroupCopyWith<$Res> {
  _$UserJoinedGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserJoinedGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? userId = null,
  }) {
    return _then(
      _value.copyWith(
            groupId:
                null == groupId
                    ? _value.groupId
                    : groupId // ignore: cast_nullable_to_non_nullable
                        as String,
            groupName:
                null == groupName
                    ? _value.groupName
                    : groupName // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserJoinedGroupImplCopyWith<$Res>
    implements $UserJoinedGroupCopyWith<$Res> {
  factory _$$UserJoinedGroupImplCopyWith(
    _$UserJoinedGroupImpl value,
    $Res Function(_$UserJoinedGroupImpl) then,
  ) = __$$UserJoinedGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String groupId, String groupName, String userId});
}

/// @nodoc
class __$$UserJoinedGroupImplCopyWithImpl<$Res>
    extends _$UserJoinedGroupCopyWithImpl<$Res, _$UserJoinedGroupImpl>
    implements _$$UserJoinedGroupImplCopyWith<$Res> {
  __$$UserJoinedGroupImplCopyWithImpl(
    _$UserJoinedGroupImpl _value,
    $Res Function(_$UserJoinedGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserJoinedGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? groupName = null,
    Object? userId = null,
  }) {
    return _then(
      _$UserJoinedGroupImpl(
        groupId:
            null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                    as String,
        groupName:
            null == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$UserJoinedGroupImpl implements _UserJoinedGroup {
  const _$UserJoinedGroupImpl({
    required this.groupId,
    required this.groupName,
    required this.userId,
  });

  factory _$UserJoinedGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserJoinedGroupImplFromJson(json);

  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final String userId;

  @override
  String toString() {
    return 'UserJoinedGroup(groupId: $groupId, groupName: $groupName, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserJoinedGroupImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, groupId, groupName, userId);

  /// Create a copy of UserJoinedGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserJoinedGroupImplCopyWith<_$UserJoinedGroupImpl> get copyWith =>
      __$$UserJoinedGroupImplCopyWithImpl<_$UserJoinedGroupImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserJoinedGroupImplToJson(this);
  }
}

abstract class _UserJoinedGroup implements UserJoinedGroup {
  const factory _UserJoinedGroup({
    required final String groupId,
    required final String groupName,
    required final String userId,
  }) = _$UserJoinedGroupImpl;

  factory _UserJoinedGroup.fromJson(Map<String, dynamic> json) =
      _$UserJoinedGroupImpl.fromJson;

  @override
  String get groupId;
  @override
  String get groupName;
  @override
  String get userId;

  /// Create a copy of UserJoinedGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserJoinedGroupImplCopyWith<_$UserJoinedGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserJoinedGroups _$UserJoinedGroupsFromJson(Map<String, dynamic> json) {
  return _UserJoinedGroups.fromJson(json);
}

/// @nodoc
mixin _$UserJoinedGroups {
  List<UserJoinedGroup> get groups => throw _privateConstructorUsedError;

  /// Serializes this UserJoinedGroups to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserJoinedGroups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserJoinedGroupsCopyWith<UserJoinedGroups> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserJoinedGroupsCopyWith<$Res> {
  factory $UserJoinedGroupsCopyWith(
    UserJoinedGroups value,
    $Res Function(UserJoinedGroups) then,
  ) = _$UserJoinedGroupsCopyWithImpl<$Res, UserJoinedGroups>;
  @useResult
  $Res call({List<UserJoinedGroup> groups});
}

/// @nodoc
class _$UserJoinedGroupsCopyWithImpl<$Res, $Val extends UserJoinedGroups>
    implements $UserJoinedGroupsCopyWith<$Res> {
  _$UserJoinedGroupsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserJoinedGroups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groups = null}) {
    return _then(
      _value.copyWith(
            groups:
                null == groups
                    ? _value.groups
                    : groups // ignore: cast_nullable_to_non_nullable
                        as List<UserJoinedGroup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserJoinedGroupsImplCopyWith<$Res>
    implements $UserJoinedGroupsCopyWith<$Res> {
  factory _$$UserJoinedGroupsImplCopyWith(
    _$UserJoinedGroupsImpl value,
    $Res Function(_$UserJoinedGroupsImpl) then,
  ) = __$$UserJoinedGroupsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<UserJoinedGroup> groups});
}

/// @nodoc
class __$$UserJoinedGroupsImplCopyWithImpl<$Res>
    extends _$UserJoinedGroupsCopyWithImpl<$Res, _$UserJoinedGroupsImpl>
    implements _$$UserJoinedGroupsImplCopyWith<$Res> {
  __$$UserJoinedGroupsImplCopyWithImpl(
    _$UserJoinedGroupsImpl _value,
    $Res Function(_$UserJoinedGroupsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserJoinedGroups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? groups = null}) {
    return _then(
      _$UserJoinedGroupsImpl(
        groups:
            null == groups
                ? _value._groups
                : groups // ignore: cast_nullable_to_non_nullable
                    as List<UserJoinedGroup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserJoinedGroupsImpl implements _UserJoinedGroups {
  const _$UserJoinedGroupsImpl({required final List<UserJoinedGroup> groups})
    : _groups = groups;

  factory _$UserJoinedGroupsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserJoinedGroupsImplFromJson(json);

  final List<UserJoinedGroup> _groups;
  @override
  List<UserJoinedGroup> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  String toString() {
    return 'UserJoinedGroups(groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserJoinedGroupsImpl &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_groups));

  /// Create a copy of UserJoinedGroups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserJoinedGroupsImplCopyWith<_$UserJoinedGroupsImpl> get copyWith =>
      __$$UserJoinedGroupsImplCopyWithImpl<_$UserJoinedGroupsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserJoinedGroupsImplToJson(this);
  }
}

abstract class _UserJoinedGroups implements UserJoinedGroups {
  const factory _UserJoinedGroups({
    required final List<UserJoinedGroup> groups,
  }) = _$UserJoinedGroupsImpl;

  factory _UserJoinedGroups.fromJson(Map<String, dynamic> json) =
      _$UserJoinedGroupsImpl.fromJson;

  @override
  List<UserJoinedGroup> get groups;

  /// Create a copy of UserJoinedGroups
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserJoinedGroupsImplCopyWith<_$UserJoinedGroupsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
