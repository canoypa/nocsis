// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventList {

 List<EventData> get items;
/// Create a copy of EventList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventListCopyWith<EventList> get copyWith => _$EventListCopyWithImpl<EventList>(this as EventList, _$identity);

  /// Serializes this EventList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventList&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'EventList(items: $items)';
}


}

/// @nodoc
abstract mixin class $EventListCopyWith<$Res>  {
  factory $EventListCopyWith(EventList value, $Res Function(EventList) _then) = _$EventListCopyWithImpl;
@useResult
$Res call({
 List<EventData> items
});




}
/// @nodoc
class _$EventListCopyWithImpl<$Res>
    implements $EventListCopyWith<$Res> {
  _$EventListCopyWithImpl(this._self, this._then);

  final EventList _self;
  final $Res Function(EventList) _then;

/// Create a copy of EventList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EventData>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _EventList implements EventList {
  const _EventList({required final  List<EventData> items}): _items = items;
  factory _EventList.fromJson(Map<String, dynamic> json) => _$EventListFromJson(json);

 final  List<EventData> _items;
@override List<EventData> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of EventList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventListCopyWith<_EventList> get copyWith => __$EventListCopyWithImpl<_EventList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventList&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'EventList(items: $items)';
}


}

/// @nodoc
abstract mixin class _$EventListCopyWith<$Res> implements $EventListCopyWith<$Res> {
  factory _$EventListCopyWith(_EventList value, $Res Function(_EventList) _then) = __$EventListCopyWithImpl;
@override @useResult
$Res call({
 List<EventData> items
});




}
/// @nodoc
class __$EventListCopyWithImpl<$Res>
    implements _$EventListCopyWith<$Res> {
  __$EventListCopyWithImpl(this._self, this._then);

  final _EventList _self;
  final $Res Function(_EventList) _then;

/// Create a copy of EventList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_EventList(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EventData>,
  ));
}


}


/// @nodoc
mixin _$EventData {

 String get title; bool get isAllDay;@LocalDateTimeConverter() DateTime get startAt;@LocalDateTimeConverter() DateTime get endAt;
/// Create a copy of EventData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDataCopyWith<EventData> get copyWith => _$EventDataCopyWithImpl<EventData>(this as EventData, _$identity);

  /// Serializes this EventData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventData&&(identical(other.title, title) || other.title == title)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,isAllDay,startAt,endAt);

@override
String toString() {
  return 'EventData(title: $title, isAllDay: $isAllDay, startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class $EventDataCopyWith<$Res>  {
  factory $EventDataCopyWith(EventData value, $Res Function(EventData) _then) = _$EventDataCopyWithImpl;
@useResult
$Res call({
 String title, bool isAllDay,@LocalDateTimeConverter() DateTime startAt,@LocalDateTimeConverter() DateTime endAt
});




}
/// @nodoc
class _$EventDataCopyWithImpl<$Res>
    implements $EventDataCopyWith<$Res> {
  _$EventDataCopyWithImpl(this._self, this._then);

  final EventData _self;
  final $Res Function(EventData) _then;

/// Create a copy of EventData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? isAllDay = null,Object? startAt = null,Object? endAt = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _EventData implements EventData {
  const _EventData({required this.title, required this.isAllDay, @LocalDateTimeConverter() required this.startAt, @LocalDateTimeConverter() required this.endAt});
  factory _EventData.fromJson(Map<String, dynamic> json) => _$EventDataFromJson(json);

@override final  String title;
@override final  bool isAllDay;
@override@LocalDateTimeConverter() final  DateTime startAt;
@override@LocalDateTimeConverter() final  DateTime endAt;

/// Create a copy of EventData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDataCopyWith<_EventData> get copyWith => __$EventDataCopyWithImpl<_EventData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventData&&(identical(other.title, title) || other.title == title)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,isAllDay,startAt,endAt);

@override
String toString() {
  return 'EventData(title: $title, isAllDay: $isAllDay, startAt: $startAt, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class _$EventDataCopyWith<$Res> implements $EventDataCopyWith<$Res> {
  factory _$EventDataCopyWith(_EventData value, $Res Function(_EventData) _then) = __$EventDataCopyWithImpl;
@override @useResult
$Res call({
 String title, bool isAllDay,@LocalDateTimeConverter() DateTime startAt,@LocalDateTimeConverter() DateTime endAt
});




}
/// @nodoc
class __$EventDataCopyWithImpl<$Res>
    implements _$EventDataCopyWith<$Res> {
  __$EventDataCopyWithImpl(this._self, this._then);

  final _EventData _self;
  final $Res Function(_EventData) _then;

/// Create a copy of EventData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? isAllDay = null,Object? startAt = null,Object? endAt = null,}) {
  return _then(_EventData(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
