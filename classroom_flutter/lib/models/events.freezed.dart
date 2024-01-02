// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EventList _$EventListFromJson(Map<String, dynamic> json) {
  return _EventList.fromJson(json);
}

/// @nodoc
mixin _$EventList {
  List<EventData> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventListCopyWith<EventList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventListCopyWith<$Res> {
  factory $EventListCopyWith(EventList value, $Res Function(EventList) then) =
      _$EventListCopyWithImpl<$Res, EventList>;
  @useResult
  $Res call({List<EventData> items});
}

/// @nodoc
class _$EventListCopyWithImpl<$Res, $Val extends EventList>
    implements $EventListCopyWith<$Res> {
  _$EventListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<EventData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventListImplCopyWith<$Res>
    implements $EventListCopyWith<$Res> {
  factory _$$EventListImplCopyWith(
          _$EventListImpl value, $Res Function(_$EventListImpl) then) =
      __$$EventListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<EventData> items});
}

/// @nodoc
class __$$EventListImplCopyWithImpl<$Res>
    extends _$EventListCopyWithImpl<$Res, _$EventListImpl>
    implements _$$EventListImplCopyWith<$Res> {
  __$$EventListImplCopyWithImpl(
      _$EventListImpl _value, $Res Function(_$EventListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$EventListImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<EventData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventListImpl implements _EventList {
  const _$EventListImpl({required final List<EventData> items})
      : _items = items;

  factory _$EventListImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventListImplFromJson(json);

  final List<EventData> _items;
  @override
  List<EventData> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'EventList(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventListImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventListImplCopyWith<_$EventListImpl> get copyWith =>
      __$$EventListImplCopyWithImpl<_$EventListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventListImplToJson(
      this,
    );
  }
}

abstract class _EventList implements EventList {
  const factory _EventList({required final List<EventData> items}) =
      _$EventListImpl;

  factory _EventList.fromJson(Map<String, dynamic> json) =
      _$EventListImpl.fromJson;

  @override
  List<EventData> get items;
  @override
  @JsonKey(ignore: true)
  _$$EventListImplCopyWith<_$EventListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventData _$EventDataFromJson(Map<String, dynamic> json) {
  return _EventData.fromJson(json);
}

/// @nodoc
mixin _$EventData {
  String get title => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  DateTime get startAt => throw _privateConstructorUsedError;
  DateTime get endAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventDataCopyWith<EventData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventDataCopyWith<$Res> {
  factory $EventDataCopyWith(EventData value, $Res Function(EventData) then) =
      _$EventDataCopyWithImpl<$Res, EventData>;
  @useResult
  $Res call({String title, bool isAllDay, DateTime startAt, DateTime endAt});
}

/// @nodoc
class _$EventDataCopyWithImpl<$Res, $Val extends EventData>
    implements $EventDataCopyWith<$Res> {
  _$EventDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? isAllDay = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      startAt: null == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventDataImplCopyWith<$Res>
    implements $EventDataCopyWith<$Res> {
  factory _$$EventDataImplCopyWith(
          _$EventDataImpl value, $Res Function(_$EventDataImpl) then) =
      __$$EventDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, bool isAllDay, DateTime startAt, DateTime endAt});
}

/// @nodoc
class __$$EventDataImplCopyWithImpl<$Res>
    extends _$EventDataCopyWithImpl<$Res, _$EventDataImpl>
    implements _$$EventDataImplCopyWith<$Res> {
  __$$EventDataImplCopyWithImpl(
      _$EventDataImpl _value, $Res Function(_$EventDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? isAllDay = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(_$EventDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      startAt: null == startAt
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventDataImpl implements _EventData {
  const _$EventDataImpl(
      {required this.title,
      required this.isAllDay,
      required this.startAt,
      required this.endAt});

  factory _$EventDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventDataImplFromJson(json);

  @override
  final String title;
  @override
  final bool isAllDay;
  @override
  final DateTime startAt;
  @override
  final DateTime endAt;

  @override
  String toString() {
    return 'EventData(title: $title, isAllDay: $isAllDay, startAt: $startAt, endAt: $endAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, isAllDay, startAt, endAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventDataImplCopyWith<_$EventDataImpl> get copyWith =>
      __$$EventDataImplCopyWithImpl<_$EventDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventDataImplToJson(
      this,
    );
  }
}

abstract class _EventData implements EventData {
  const factory _EventData(
      {required final String title,
      required final bool isAllDay,
      required final DateTime startAt,
      required final DateTime endAt}) = _$EventDataImpl;

  factory _EventData.fromJson(Map<String, dynamic> json) =
      _$EventDataImpl.fromJson;

  @override
  String get title;
  @override
  bool get isAllDay;
  @override
  DateTime get startAt;
  @override
  DateTime get endAt;
  @override
  @JsonKey(ignore: true)
  _$$EventDataImplCopyWith<_$EventDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
