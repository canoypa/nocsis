// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'monthly_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MonthEvents _$MonthEventsFromJson(Map<String, dynamic> json) {
  return _MonthEvents.fromJson(json);
}

/// @nodoc
mixin _$MonthEvents {
  String get month => throw _privateConstructorUsedError;
  List<CalendarEvent> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonthEventsCopyWith<MonthEvents> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthEventsCopyWith<$Res> {
  factory $MonthEventsCopyWith(
          MonthEvents value, $Res Function(MonthEvents) then) =
      _$MonthEventsCopyWithImpl<$Res>;
  $Res call({String month, List<CalendarEvent> items});
}

/// @nodoc
class _$MonthEventsCopyWithImpl<$Res> implements $MonthEventsCopyWith<$Res> {
  _$MonthEventsCopyWithImpl(this._value, this._then);

  final MonthEvents _value;
  // ignore: unused_field
  final $Res Function(MonthEvents) _then;

  @override
  $Res call({
    Object? month = freezed,
    Object? items = freezed,
  }) {
    return _then(_value.copyWith(
      month: month == freezed
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
abstract class _$MonthEventsCopyWith<$Res>
    implements $MonthEventsCopyWith<$Res> {
  factory _$MonthEventsCopyWith(
          _MonthEvents value, $Res Function(_MonthEvents) then) =
      __$MonthEventsCopyWithImpl<$Res>;
  @override
  $Res call({String month, List<CalendarEvent> items});
}

/// @nodoc
class __$MonthEventsCopyWithImpl<$Res> extends _$MonthEventsCopyWithImpl<$Res>
    implements _$MonthEventsCopyWith<$Res> {
  __$MonthEventsCopyWithImpl(
      _MonthEvents _value, $Res Function(_MonthEvents) _then)
      : super(_value, (v) => _then(v as _MonthEvents));

  @override
  _MonthEvents get _value => super._value as _MonthEvents;

  @override
  $Res call({
    Object? month = freezed,
    Object? items = freezed,
  }) {
    return _then(_MonthEvents(
      month: month == freezed
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MonthEvents implements _MonthEvents {
  const _$_MonthEvents(
      {required this.month, required final List<CalendarEvent> items})
      : _items = items;

  factory _$_MonthEvents.fromJson(Map<String, dynamic> json) =>
      _$$_MonthEventsFromJson(json);

  @override
  final String month;
  final List<CalendarEvent> _items;
  @override
  List<CalendarEvent> get items {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthEvents(month: $month, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MonthEvents &&
            const DeepCollectionEquality().equals(other.month, month) &&
            const DeepCollectionEquality().equals(other.items, items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(month),
      const DeepCollectionEquality().hash(items));

  @JsonKey(ignore: true)
  @override
  _$MonthEventsCopyWith<_MonthEvents> get copyWith =>
      __$MonthEventsCopyWithImpl<_MonthEvents>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MonthEventsToJson(this);
  }
}

abstract class _MonthEvents implements MonthEvents {
  const factory _MonthEvents(
      {required final String month,
      required final List<CalendarEvent> items}) = _$_MonthEvents;

  factory _MonthEvents.fromJson(Map<String, dynamic> json) =
      _$_MonthEvents.fromJson;

  @override
  String get month => throw _privateConstructorUsedError;
  @override
  List<CalendarEvent> get items => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$MonthEventsCopyWith<_MonthEvents> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlyEvents _$MonthlyEventsFromJson(Map<String, dynamic> json) {
  return _MonthlyEvents.fromJson(json);
}

/// @nodoc
mixin _$MonthlyEvents {
  List<MonthEvents> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonthlyEventsCopyWith<MonthlyEvents> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyEventsCopyWith<$Res> {
  factory $MonthlyEventsCopyWith(
          MonthlyEvents value, $Res Function(MonthlyEvents) then) =
      _$MonthlyEventsCopyWithImpl<$Res>;
  $Res call({List<MonthEvents> items});
}

/// @nodoc
class _$MonthlyEventsCopyWithImpl<$Res>
    implements $MonthlyEventsCopyWith<$Res> {
  _$MonthlyEventsCopyWithImpl(this._value, this._then);

  final MonthlyEvents _value;
  // ignore: unused_field
  final $Res Function(MonthlyEvents) _then;

  @override
  $Res call({
    Object? items = freezed,
  }) {
    return _then(_value.copyWith(
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MonthEvents>,
    ));
  }
}

/// @nodoc
abstract class _$MonthlyEventsCopyWith<$Res>
    implements $MonthlyEventsCopyWith<$Res> {
  factory _$MonthlyEventsCopyWith(
          _MonthlyEvents value, $Res Function(_MonthlyEvents) then) =
      __$MonthlyEventsCopyWithImpl<$Res>;
  @override
  $Res call({List<MonthEvents> items});
}

/// @nodoc
class __$MonthlyEventsCopyWithImpl<$Res>
    extends _$MonthlyEventsCopyWithImpl<$Res>
    implements _$MonthlyEventsCopyWith<$Res> {
  __$MonthlyEventsCopyWithImpl(
      _MonthlyEvents _value, $Res Function(_MonthlyEvents) _then)
      : super(_value, (v) => _then(v as _MonthlyEvents));

  @override
  _MonthlyEvents get _value => super._value as _MonthlyEvents;

  @override
  $Res call({
    Object? items = freezed,
  }) {
    return _then(_MonthlyEvents(
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MonthEvents>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MonthlyEvents implements _MonthlyEvents {
  const _$_MonthlyEvents({required final List<MonthEvents> items})
      : _items = items;

  factory _$_MonthlyEvents.fromJson(Map<String, dynamic> json) =>
      _$$_MonthlyEventsFromJson(json);

  final List<MonthEvents> _items;
  @override
  List<MonthEvents> get items {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthlyEvents(items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MonthlyEvents &&
            const DeepCollectionEquality().equals(other.items, items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(items));

  @JsonKey(ignore: true)
  @override
  _$MonthlyEventsCopyWith<_MonthlyEvents> get copyWith =>
      __$MonthlyEventsCopyWithImpl<_MonthlyEvents>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MonthlyEventsToJson(this);
  }
}

abstract class _MonthlyEvents implements MonthlyEvents {
  const factory _MonthlyEvents({required final List<MonthEvents> items}) =
      _$_MonthlyEvents;

  factory _MonthlyEvents.fromJson(Map<String, dynamic> json) =
      _$_MonthlyEvents.fromJson;

  @override
  List<MonthEvents> get items => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$MonthlyEventsCopyWith<_MonthlyEvents> get copyWith =>
      throw _privateConstructorUsedError;
}
