// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthlyEventList {

 List<MonthEventList> get items;
/// Create a copy of MonthlyEventList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyEventListCopyWith<MonthlyEventList> get copyWith => _$MonthlyEventListCopyWithImpl<MonthlyEventList>(this as MonthlyEventList, _$identity);

  /// Serializes this MonthlyEventList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyEventList&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MonthlyEventList(items: $items)';
}


}

/// @nodoc
abstract mixin class $MonthlyEventListCopyWith<$Res>  {
  factory $MonthlyEventListCopyWith(MonthlyEventList value, $Res Function(MonthlyEventList) _then) = _$MonthlyEventListCopyWithImpl;
@useResult
$Res call({
 List<MonthEventList> items
});




}
/// @nodoc
class _$MonthlyEventListCopyWithImpl<$Res>
    implements $MonthlyEventListCopyWith<$Res> {
  _$MonthlyEventListCopyWithImpl(this._self, this._then);

  final MonthlyEventList _self;
  final $Res Function(MonthlyEventList) _then;

/// Create a copy of MonthlyEventList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MonthEventList>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MonthlyEventList implements MonthlyEventList {
  const _MonthlyEventList({required final  List<MonthEventList> items}): _items = items;
  factory _MonthlyEventList.fromJson(Map<String, dynamic> json) => _$MonthlyEventListFromJson(json);

 final  List<MonthEventList> _items;
@override List<MonthEventList> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MonthlyEventList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyEventListCopyWith<_MonthlyEventList> get copyWith => __$MonthlyEventListCopyWithImpl<_MonthlyEventList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyEventListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyEventList&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MonthlyEventList(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MonthlyEventListCopyWith<$Res> implements $MonthlyEventListCopyWith<$Res> {
  factory _$MonthlyEventListCopyWith(_MonthlyEventList value, $Res Function(_MonthlyEventList) _then) = __$MonthlyEventListCopyWithImpl;
@override @useResult
$Res call({
 List<MonthEventList> items
});




}
/// @nodoc
class __$MonthlyEventListCopyWithImpl<$Res>
    implements _$MonthlyEventListCopyWith<$Res> {
  __$MonthlyEventListCopyWithImpl(this._self, this._then);

  final _MonthlyEventList _self;
  final $Res Function(_MonthlyEventList) _then;

/// Create a copy of MonthlyEventList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MonthlyEventList(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MonthEventList>,
  ));
}


}


/// @nodoc
mixin _$MonthEventList {

 String get month; List<EventData> get items;
/// Create a copy of MonthEventList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthEventListCopyWith<MonthEventList> get copyWith => _$MonthEventListCopyWithImpl<MonthEventList>(this as MonthEventList, _$identity);

  /// Serializes this MonthEventList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthEventList&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MonthEventList(month: $month, items: $items)';
}


}

/// @nodoc
abstract mixin class $MonthEventListCopyWith<$Res>  {
  factory $MonthEventListCopyWith(MonthEventList value, $Res Function(MonthEventList) _then) = _$MonthEventListCopyWithImpl;
@useResult
$Res call({
 String month, List<EventData> items
});




}
/// @nodoc
class _$MonthEventListCopyWithImpl<$Res>
    implements $MonthEventListCopyWith<$Res> {
  _$MonthEventListCopyWithImpl(this._self, this._then);

  final MonthEventList _self;
  final $Res Function(MonthEventList) _then;

/// Create a copy of MonthEventList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? items = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EventData>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MonthEventList implements MonthEventList {
  const _MonthEventList({required this.month, required final  List<EventData> items}): _items = items;
  factory _MonthEventList.fromJson(Map<String, dynamic> json) => _$MonthEventListFromJson(json);

@override final  String month;
 final  List<EventData> _items;
@override List<EventData> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MonthEventList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthEventListCopyWith<_MonthEventList> get copyWith => __$MonthEventListCopyWithImpl<_MonthEventList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthEventListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthEventList&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MonthEventList(month: $month, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MonthEventListCopyWith<$Res> implements $MonthEventListCopyWith<$Res> {
  factory _$MonthEventListCopyWith(_MonthEventList value, $Res Function(_MonthEventList) _then) = __$MonthEventListCopyWithImpl;
@override @useResult
$Res call({
 String month, List<EventData> items
});




}
/// @nodoc
class __$MonthEventListCopyWithImpl<$Res>
    implements _$MonthEventListCopyWith<$Res> {
  __$MonthEventListCopyWithImpl(this._self, this._then);

  final _MonthEventList _self;
  final $Res Function(_MonthEventList) _then;

/// Create a copy of MonthEventList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? items = null,}) {
  return _then(_MonthEventList(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EventData>,
  ));
}


}

// dart format on
