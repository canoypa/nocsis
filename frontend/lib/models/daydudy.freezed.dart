// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daydudy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Daydudy {

 String get name; int get stuNo;
/// Create a copy of Daydudy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DaydudyCopyWith<Daydudy> get copyWith => _$DaydudyCopyWithImpl<Daydudy>(this as Daydudy, _$identity);

  /// Serializes this Daydudy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Daydudy&&(identical(other.name, name) || other.name == name)&&(identical(other.stuNo, stuNo) || other.stuNo == stuNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,stuNo);

@override
String toString() {
  return 'Daydudy(name: $name, stuNo: $stuNo)';
}


}

/// @nodoc
abstract mixin class $DaydudyCopyWith<$Res>  {
  factory $DaydudyCopyWith(Daydudy value, $Res Function(Daydudy) _then) = _$DaydudyCopyWithImpl;
@useResult
$Res call({
 String name, int stuNo
});




}
/// @nodoc
class _$DaydudyCopyWithImpl<$Res>
    implements $DaydudyCopyWith<$Res> {
  _$DaydudyCopyWithImpl(this._self, this._then);

  final Daydudy _self;
  final $Res Function(Daydudy) _then;

/// Create a copy of Daydudy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? stuNo = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stuNo: null == stuNo ? _self.stuNo : stuNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Daydudy implements Daydudy {
  const _Daydudy({required this.name, required this.stuNo});
  factory _Daydudy.fromJson(Map<String, dynamic> json) => _$DaydudyFromJson(json);

@override final  String name;
@override final  int stuNo;

/// Create a copy of Daydudy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DaydudyCopyWith<_Daydudy> get copyWith => __$DaydudyCopyWithImpl<_Daydudy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DaydudyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Daydudy&&(identical(other.name, name) || other.name == name)&&(identical(other.stuNo, stuNo) || other.stuNo == stuNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,stuNo);

@override
String toString() {
  return 'Daydudy(name: $name, stuNo: $stuNo)';
}


}

/// @nodoc
abstract mixin class _$DaydudyCopyWith<$Res> implements $DaydudyCopyWith<$Res> {
  factory _$DaydudyCopyWith(_Daydudy value, $Res Function(_Daydudy) _then) = __$DaydudyCopyWithImpl;
@override @useResult
$Res call({
 String name, int stuNo
});




}
/// @nodoc
class __$DaydudyCopyWithImpl<$Res>
    implements _$DaydudyCopyWith<$Res> {
  __$DaydudyCopyWithImpl(this._self, this._then);

  final _Daydudy _self;
  final $Res Function(_Daydudy) _then;

/// Create a copy of Daydudy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? stuNo = null,}) {
  return _then(_Daydudy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stuNo: null == stuNo ? _self.stuNo : stuNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
