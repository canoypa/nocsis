// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
      _$MonthEventsCopyWithImpl<$Res, MonthEvents>;
  @useResult
  $Res call({String month, List<CalendarEvent> items});
}

/// @nodoc
class _$MonthEventsCopyWithImpl<$Res, $Val extends MonthEvents>
    implements $MonthEventsCopyWith<$Res> {
  _$MonthEventsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthEventsImplCopyWith<$Res>
    implements $MonthEventsCopyWith<$Res> {
  factory _$$MonthEventsImplCopyWith(
          _$MonthEventsImpl value, $Res Function(_$MonthEventsImpl) then) =
      __$$MonthEventsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, List<CalendarEvent> items});
}

/// @nodoc
class __$$MonthEventsImplCopyWithImpl<$Res>
    extends _$MonthEventsCopyWithImpl<$Res, _$MonthEventsImpl>
    implements _$$MonthEventsImplCopyWith<$Res> {
  __$$MonthEventsImplCopyWithImpl(
      _$MonthEventsImpl _value, $Res Function(_$MonthEventsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? items = null,
  }) {
    return _then(_$MonthEventsImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthEventsImpl implements _MonthEvents {
  const _$MonthEventsImpl(
      {required this.month, required final List<CalendarEvent> items})
      : _items = items;

  factory _$MonthEventsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthEventsImplFromJson(json);

  @override
  final String month;
  final List<CalendarEvent> _items;
  @override
  List<CalendarEvent> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthEvents(month: $month, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthEventsImpl &&
            (identical(other.month, month) || other.month == month) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, month, const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthEventsImplCopyWith<_$MonthEventsImpl> get copyWith =>
      __$$MonthEventsImplCopyWithImpl<_$MonthEventsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthEventsImplToJson(
      this,
    );
  }
}

abstract class _MonthEvents implements MonthEvents {
  const factory _MonthEvents(
      {required final String month,
      required final List<CalendarEvent> items}) = _$MonthEventsImpl;

  factory _MonthEvents.fromJson(Map<String, dynamic> json) =
      _$MonthEventsImpl.fromJson;

  @override
  String get month;
  @override
  List<CalendarEvent> get items;
  @override
  @JsonKey(ignore: true)
  _$$MonthEventsImplCopyWith<_$MonthEventsImpl> get copyWith =>
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
      _$MonthlyEventsCopyWithImpl<$Res, MonthlyEvents>;
  @useResult
  $Res call({List<MonthEvents> items});
}

/// @nodoc
class _$MonthlyEventsCopyWithImpl<$Res, $Val extends MonthlyEvents>
    implements $MonthlyEventsCopyWith<$Res> {
  _$MonthlyEventsCopyWithImpl(this._value, this._then);

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
              as List<MonthEvents>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyEventsImplCopyWith<$Res>
    implements $MonthlyEventsCopyWith<$Res> {
  factory _$$MonthlyEventsImplCopyWith(
          _$MonthlyEventsImpl value, $Res Function(_$MonthlyEventsImpl) then) =
      __$$MonthlyEventsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MonthEvents> items});
}

/// @nodoc
class __$$MonthlyEventsImplCopyWithImpl<$Res>
    extends _$MonthlyEventsCopyWithImpl<$Res, _$MonthlyEventsImpl>
    implements _$$MonthlyEventsImplCopyWith<$Res> {
  __$$MonthlyEventsImplCopyWithImpl(
      _$MonthlyEventsImpl _value, $Res Function(_$MonthlyEventsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
  }) {
    return _then(_$MonthlyEventsImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MonthEvents>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyEventsImpl implements _MonthlyEvents {
  const _$MonthlyEventsImpl({required final List<MonthEvents> items})
      : _items = items;

  factory _$MonthlyEventsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyEventsImplFromJson(json);

  final List<MonthEvents> _items;
  @override
  List<MonthEvents> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthlyEvents(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyEventsImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyEventsImplCopyWith<_$MonthlyEventsImpl> get copyWith =>
      __$$MonthlyEventsImplCopyWithImpl<_$MonthlyEventsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyEventsImplToJson(
      this,
    );
  }
}

abstract class _MonthlyEvents implements MonthlyEvents {
  const factory _MonthlyEvents({required final List<MonthEvents> items}) =
      _$MonthlyEventsImpl;

  factory _MonthlyEvents.fromJson(Map<String, dynamic> json) =
      _$MonthlyEventsImpl.fromJson;

  @override
  List<MonthEvents> get items;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyEventsImplCopyWith<_$MonthlyEventsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
