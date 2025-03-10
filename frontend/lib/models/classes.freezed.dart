// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassList {

 List<ClassData> get items;
/// Create a copy of ClassList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassListCopyWith<ClassList> get copyWith => _$ClassListCopyWithImpl<ClassList>(this as ClassList, _$identity);

  /// Serializes this ClassList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassList&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ClassList(items: $items)';
}


}

/// @nodoc
abstract mixin class $ClassListCopyWith<$Res>  {
  factory $ClassListCopyWith(ClassList value, $Res Function(ClassList) _then) = _$ClassListCopyWithImpl;
@useResult
$Res call({
 List<ClassData> items
});




}
/// @nodoc
class _$ClassListCopyWithImpl<$Res>
    implements $ClassListCopyWith<$Res> {
  _$ClassListCopyWithImpl(this._self, this._then);

  final ClassList _self;
  final $Res Function(ClassList) _then;

/// Create a copy of ClassList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ClassData>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ClassList implements ClassList {
  const _ClassList({required final  List<ClassData> items}): _items = items;
  factory _ClassList.fromJson(Map<String, dynamic> json) => _$ClassListFromJson(json);

 final  List<ClassData> _items;
@override List<ClassData> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ClassList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassListCopyWith<_ClassList> get copyWith => __$ClassListCopyWithImpl<_ClassList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassList&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ClassList(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ClassListCopyWith<$Res> implements $ClassListCopyWith<$Res> {
  factory _$ClassListCopyWith(_ClassList value, $Res Function(_ClassList) _then) = __$ClassListCopyWithImpl;
@override @useResult
$Res call({
 List<ClassData> items
});




}
/// @nodoc
class __$ClassListCopyWithImpl<$Res>
    implements _$ClassListCopyWith<$Res> {
  __$ClassListCopyWithImpl(this._self, this._then);

  final _ClassList _self;
  final $Res Function(_ClassList) _then;

/// Create a copy of ClassList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ClassList(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ClassData>,
  ));
}


}


/// @nodoc
mixin _$ClassData {

 String get title; int get period;@LocalDateTimeConverter() DateTime get startAt;@LocalDateTimeConverter() DateTime get endAt;
/// Create a copy of ClassData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassDataCopyWith<ClassData> get copyWith => _$ClassDataCopyWithImpl<ClassData>(this as ClassData, _$identity);

  /// Serializes this ClassData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassData&&(identical(other.title, title) || other.title == title)&&(identical(other.period, period) || other.period == period)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,period,startAt,endAt);

@override
String toString() {
  return 'ClassData(title: $title, period: $period, startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class $ClassDataCopyWith<$Res>  {
  factory $ClassDataCopyWith(ClassData value, $Res Function(ClassData) _then) = _$ClassDataCopyWithImpl;
@useResult
$Res call({
 String title, int period,@LocalDateTimeConverter() DateTime startAt,@LocalDateTimeConverter() DateTime endAt
});




}
/// @nodoc
class _$ClassDataCopyWithImpl<$Res>
    implements $ClassDataCopyWith<$Res> {
  _$ClassDataCopyWithImpl(this._self, this._then);

  final ClassData _self;
  final $Res Function(ClassData) _then;

/// Create a copy of ClassData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? period = null,Object? startAt = null,Object? endAt = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ClassData implements ClassData {
  const _ClassData({required this.title, required this.period, @LocalDateTimeConverter() required this.startAt, @LocalDateTimeConverter() required this.endAt});
  factory _ClassData.fromJson(Map<String, dynamic> json) => _$ClassDataFromJson(json);

@override final  String title;
@override final  int period;
@override@LocalDateTimeConverter() final  DateTime startAt;
@override@LocalDateTimeConverter() final  DateTime endAt;

/// Create a copy of ClassData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassDataCopyWith<_ClassData> get copyWith => __$ClassDataCopyWithImpl<_ClassData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassData&&(identical(other.title, title) || other.title == title)&&(identical(other.period, period) || other.period == period)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,period,startAt,endAt);

@override
String toString() {
  return 'ClassData(title: $title, period: $period, startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class _$ClassDataCopyWith<$Res> implements $ClassDataCopyWith<$Res> {
  factory _$ClassDataCopyWith(_ClassData value, $Res Function(_ClassData) _then) = __$ClassDataCopyWithImpl;
@override @useResult
$Res call({
 String title, int period,@LocalDateTimeConverter() DateTime startAt,@LocalDateTimeConverter() DateTime endAt
});




}
/// @nodoc
class __$ClassDataCopyWithImpl<$Res>
    implements _$ClassDataCopyWith<$Res> {
  __$ClassDataCopyWithImpl(this._self, this._then);

  final _ClassData _self;
  final $Res Function(_ClassData) _then;

/// Create a copy of ClassData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? period = null,Object? startAt = null,Object? endAt = null,}) {
  return _then(_ClassData(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
