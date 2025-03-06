// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daydudy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Daydudy _$DaydudyFromJson(Map<String, dynamic> json) {
  return _Daydudy.fromJson(json);
}

/// @nodoc
mixin _$Daydudy {
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  int get stuNo => throw _privateConstructorUsedError;

  /// Serializes this Daydudy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Daydudy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DaydudyCopyWith<Daydudy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DaydudyCopyWith<$Res> {
  factory $DaydudyCopyWith(Daydudy value, $Res Function(Daydudy) then) =
      _$DaydudyCopyWithImpl<$Res, Daydudy>;
  @useResult
  $Res call({String firstName, String lastName, int stuNo});
}

/// @nodoc
class _$DaydudyCopyWithImpl<$Res, $Val extends Daydudy>
    implements $DaydudyCopyWith<$Res> {
  _$DaydudyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Daydudy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? stuNo = null,
  }) {
    return _then(
      _value.copyWith(
            firstName:
                null == firstName
                    ? _value.firstName
                    : firstName // ignore: cast_nullable_to_non_nullable
                        as String,
            lastName:
                null == lastName
                    ? _value.lastName
                    : lastName // ignore: cast_nullable_to_non_nullable
                        as String,
            stuNo:
                null == stuNo
                    ? _value.stuNo
                    : stuNo // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DaydudyImplCopyWith<$Res> implements $DaydudyCopyWith<$Res> {
  factory _$$DaydudyImplCopyWith(
    _$DaydudyImpl value,
    $Res Function(_$DaydudyImpl) then,
  ) = __$$DaydudyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String firstName, String lastName, int stuNo});
}

/// @nodoc
class __$$DaydudyImplCopyWithImpl<$Res>
    extends _$DaydudyCopyWithImpl<$Res, _$DaydudyImpl>
    implements _$$DaydudyImplCopyWith<$Res> {
  __$$DaydudyImplCopyWithImpl(
    _$DaydudyImpl _value,
    $Res Function(_$DaydudyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Daydudy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? stuNo = null,
  }) {
    return _then(
      _$DaydudyImpl(
        firstName:
            null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                    as String,
        lastName:
            null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                    as String,
        stuNo:
            null == stuNo
                ? _value.stuNo
                : stuNo // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DaydudyImpl implements _Daydudy {
  const _$DaydudyImpl({
    required this.firstName,
    required this.lastName,
    required this.stuNo,
  });

  factory _$DaydudyImpl.fromJson(Map<String, dynamic> json) =>
      _$$DaydudyImplFromJson(json);

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final int stuNo;

  @override
  String toString() {
    return 'Daydudy(firstName: $firstName, lastName: $lastName, stuNo: $stuNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DaydudyImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.stuNo, stuNo) || other.stuNo == stuNo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, stuNo);

  /// Create a copy of Daydudy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DaydudyImplCopyWith<_$DaydudyImpl> get copyWith =>
      __$$DaydudyImplCopyWithImpl<_$DaydudyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DaydudyImplToJson(this);
  }
}

abstract class _Daydudy implements Daydudy {
  const factory _Daydudy({
    required final String firstName,
    required final String lastName,
    required final int stuNo,
  }) = _$DaydudyImpl;

  factory _Daydudy.fromJson(Map<String, dynamic> json) = _$DaydudyImpl.fromJson;

  @override
  String get firstName;
  @override
  String get lastName;
  @override
  int get stuNo;

  /// Create a copy of Daydudy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DaydudyImplCopyWith<_$DaydudyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
