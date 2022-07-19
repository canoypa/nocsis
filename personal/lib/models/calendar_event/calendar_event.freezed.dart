// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'calendar_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) {
  return _CalendarEvent.fromJson(json);
}

/// @nodoc
mixin _$CalendarEvent {
  String get title => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get startAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get endAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarEventCopyWith<CalendarEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventCopyWith<$Res> {
  factory $CalendarEventCopyWith(
          CalendarEvent value, $Res Function(CalendarEvent) then) =
      _$CalendarEventCopyWithImpl<$Res>;
  $Res call(
      {String title,
      bool isAllDay,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class _$CalendarEventCopyWithImpl<$Res>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._value, this._then);

  final CalendarEvent _value;
  // ignore: unused_field
  final $Res Function(CalendarEvent) _then;

  @override
  $Res call({
    Object? title = freezed,
    Object? isAllDay = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
  }) {
    return _then(_value.copyWith(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isAllDay: isAllDay == freezed
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      startAt: startAt == freezed
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: endAt == freezed
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
abstract class _$CalendarEventCopyWith<$Res>
    implements $CalendarEventCopyWith<$Res> {
  factory _$CalendarEventCopyWith(
          _CalendarEvent value, $Res Function(_CalendarEvent) then) =
      __$CalendarEventCopyWithImpl<$Res>;
  @override
  $Res call(
      {String title,
      bool isAllDay,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class __$CalendarEventCopyWithImpl<$Res>
    extends _$CalendarEventCopyWithImpl<$Res>
    implements _$CalendarEventCopyWith<$Res> {
  __$CalendarEventCopyWithImpl(
      _CalendarEvent _value, $Res Function(_CalendarEvent) _then)
      : super(_value, (v) => _then(v as _CalendarEvent));

  @override
  _CalendarEvent get _value => super._value as _CalendarEvent;

  @override
  $Res call({
    Object? title = freezed,
    Object? isAllDay = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
  }) {
    return _then(_CalendarEvent(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isAllDay: isAllDay == freezed
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      startAt: startAt == freezed
          ? _value.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: endAt == freezed
          ? _value.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CalendarEvent implements _CalendarEvent {
  const _$_CalendarEvent(
      {required this.title,
      required this.isAllDay,
      @DateTimeConverter() required this.startAt,
      @DateTimeConverter() required this.endAt});

  factory _$_CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$$_CalendarEventFromJson(json);

  @override
  final String title;
  @override
  final bool isAllDay;
  @override
  @DateTimeConverter()
  final DateTime startAt;
  @override
  @DateTimeConverter()
  final DateTime endAt;

  @override
  String toString() {
    return 'CalendarEvent(title: $title, isAllDay: $isAllDay, startAt: $startAt, endAt: $endAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalendarEvent &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.isAllDay, isAllDay) &&
            const DeepCollectionEquality().equals(other.startAt, startAt) &&
            const DeepCollectionEquality().equals(other.endAt, endAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(isAllDay),
      const DeepCollectionEquality().hash(startAt),
      const DeepCollectionEquality().hash(endAt));

  @JsonKey(ignore: true)
  @override
  _$CalendarEventCopyWith<_CalendarEvent> get copyWith =>
      __$CalendarEventCopyWithImpl<_CalendarEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CalendarEventToJson(this);
  }
}

abstract class _CalendarEvent implements CalendarEvent {
  const factory _CalendarEvent(
      {required final String title,
      required final bool isAllDay,
      @DateTimeConverter() required final DateTime startAt,
      @DateTimeConverter() required final DateTime endAt}) = _$_CalendarEvent;

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) =
      _$_CalendarEvent.fromJson;

  @override
  String get title => throw _privateConstructorUsedError;
  @override
  bool get isAllDay => throw _privateConstructorUsedError;
  @override
  @DateTimeConverter()
  DateTime get startAt => throw _privateConstructorUsedError;
  @override
  @DateTimeConverter()
  DateTime get endAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$CalendarEventCopyWith<_CalendarEvent> get copyWith =>
      throw _privateConstructorUsedError;
}
