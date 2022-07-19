// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'calendar_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalendarClass _$CalendarClassFromJson(Map<String, dynamic> json) {
  return _CalendarClass.fromJson(json);
}

/// @nodoc
mixin _$CalendarClass {
  String get title => throw _privateConstructorUsedError;
  int get period => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get startAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get endAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarClassCopyWith<CalendarClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarClassCopyWith<$Res> {
  factory $CalendarClassCopyWith(
          CalendarClass value, $Res Function(CalendarClass) then) =
      _$CalendarClassCopyWithImpl<$Res>;
  $Res call(
      {String title,
      int period,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class _$CalendarClassCopyWithImpl<$Res>
    implements $CalendarClassCopyWith<$Res> {
  _$CalendarClassCopyWithImpl(this._value, this._then);

  final CalendarClass _value;
  // ignore: unused_field
  final $Res Function(CalendarClass) _then;

  @override
  $Res call({
    Object? title = freezed,
    Object? period = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
  }) {
    return _then(_value.copyWith(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      period: period == freezed
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$CalendarClassCopyWith<$Res>
    implements $CalendarClassCopyWith<$Res> {
  factory _$CalendarClassCopyWith(
          _CalendarClass value, $Res Function(_CalendarClass) then) =
      __$CalendarClassCopyWithImpl<$Res>;
  @override
  $Res call(
      {String title,
      int period,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class __$CalendarClassCopyWithImpl<$Res>
    extends _$CalendarClassCopyWithImpl<$Res>
    implements _$CalendarClassCopyWith<$Res> {
  __$CalendarClassCopyWithImpl(
      _CalendarClass _value, $Res Function(_CalendarClass) _then)
      : super(_value, (v) => _then(v as _CalendarClass));

  @override
  _CalendarClass get _value => super._value as _CalendarClass;

  @override
  $Res call({
    Object? title = freezed,
    Object? period = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
  }) {
    return _then(_CalendarClass(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      period: period == freezed
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$_CalendarClass implements _CalendarClass {
  const _$_CalendarClass(
      {required this.title,
      required this.period,
      @DateTimeConverter() required this.startAt,
      @DateTimeConverter() required this.endAt});

  factory _$_CalendarClass.fromJson(Map<String, dynamic> json) =>
      _$$_CalendarClassFromJson(json);

  @override
  final String title;
  @override
  final int period;
  @override
  @DateTimeConverter()
  final DateTime startAt;
  @override
  @DateTimeConverter()
  final DateTime endAt;

  @override
  String toString() {
    return 'CalendarClass(title: $title, period: $period, startAt: $startAt, endAt: $endAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalendarClass &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.period, period) &&
            const DeepCollectionEquality().equals(other.startAt, startAt) &&
            const DeepCollectionEquality().equals(other.endAt, endAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(period),
      const DeepCollectionEquality().hash(startAt),
      const DeepCollectionEquality().hash(endAt));

  @JsonKey(ignore: true)
  @override
  _$CalendarClassCopyWith<_CalendarClass> get copyWith =>
      __$CalendarClassCopyWithImpl<_CalendarClass>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CalendarClassToJson(this);
  }
}

abstract class _CalendarClass implements CalendarClass {
  const factory _CalendarClass(
      {required final String title,
      required final int period,
      @DateTimeConverter() required final DateTime startAt,
      @DateTimeConverter() required final DateTime endAt}) = _$_CalendarClass;

  factory _CalendarClass.fromJson(Map<String, dynamic> json) =
      _$_CalendarClass.fromJson;

  @override
  String get title => throw _privateConstructorUsedError;
  @override
  int get period => throw _privateConstructorUsedError;
  @override
  @DateTimeConverter()
  DateTime get startAt => throw _privateConstructorUsedError;
  @override
  @DateTimeConverter()
  DateTime get endAt => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$CalendarClassCopyWith<_CalendarClass> get copyWith =>
      throw _privateConstructorUsedError;
}
