// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'calendar_event_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalendarEventList _$CalendarEventListFromJson(Map<String, dynamic> json) {
  return _CalendarEventList.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventList {
  bool get isEmpty => throw _privateConstructorUsedError;
  List<CalendarEvent> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarEventListCopyWith<CalendarEventList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventListCopyWith<$Res> {
  factory $CalendarEventListCopyWith(
          CalendarEventList value, $Res Function(CalendarEventList) then) =
      _$CalendarEventListCopyWithImpl<$Res>;
  $Res call({bool isEmpty, List<CalendarEvent> items});
}

/// @nodoc
class _$CalendarEventListCopyWithImpl<$Res>
    implements $CalendarEventListCopyWith<$Res> {
  _$CalendarEventListCopyWithImpl(this._value, this._then);

  final CalendarEventList _value;
  // ignore: unused_field
  final $Res Function(CalendarEventList) _then;

  @override
  $Res call({
    Object? isEmpty = freezed,
    Object? items = freezed,
  }) {
    return _then(_value.copyWith(
      isEmpty: isEmpty == freezed
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
abstract class _$CalendarEventListCopyWith<$Res>
    implements $CalendarEventListCopyWith<$Res> {
  factory _$CalendarEventListCopyWith(
          _CalendarEventList value, $Res Function(_CalendarEventList) then) =
      __$CalendarEventListCopyWithImpl<$Res>;
  @override
  $Res call({bool isEmpty, List<CalendarEvent> items});
}

/// @nodoc
class __$CalendarEventListCopyWithImpl<$Res>
    extends _$CalendarEventListCopyWithImpl<$Res>
    implements _$CalendarEventListCopyWith<$Res> {
  __$CalendarEventListCopyWithImpl(
      _CalendarEventList _value, $Res Function(_CalendarEventList) _then)
      : super(_value, (v) => _then(v as _CalendarEventList));

  @override
  _CalendarEventList get _value => super._value as _CalendarEventList;

  @override
  $Res call({
    Object? isEmpty = freezed,
    Object? items = freezed,
  }) {
    return _then(_CalendarEventList(
      isEmpty: isEmpty == freezed
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CalendarEventList implements _CalendarEventList {
  const _$_CalendarEventList(
      {required this.isEmpty, required final List<CalendarEvent> items})
      : _items = items;

  factory _$_CalendarEventList.fromJson(Map<String, dynamic> json) =>
      _$$_CalendarEventListFromJson(json);

  @override
  final bool isEmpty;
  final List<CalendarEvent> _items;
  @override
  List<CalendarEvent> get items {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CalendarEventList(isEmpty: $isEmpty, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalendarEventList &&
            const DeepCollectionEquality().equals(other.isEmpty, isEmpty) &&
            const DeepCollectionEquality().equals(other.items, items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(isEmpty),
      const DeepCollectionEquality().hash(items));

  @JsonKey(ignore: true)
  @override
  _$CalendarEventListCopyWith<_CalendarEventList> get copyWith =>
      __$CalendarEventListCopyWithImpl<_CalendarEventList>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CalendarEventListToJson(this);
  }
}

abstract class _CalendarEventList implements CalendarEventList {
  const factory _CalendarEventList(
      {required final bool isEmpty,
      required final List<CalendarEvent> items}) = _$_CalendarEventList;

  factory _CalendarEventList.fromJson(Map<String, dynamic> json) =
      _$_CalendarEventList.fromJson;

  @override
  bool get isEmpty => throw _privateConstructorUsedError;
  @override
  List<CalendarEvent> get items => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$CalendarEventListCopyWith<_CalendarEventList> get copyWith =>
      throw _privateConstructorUsedError;
}
