// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
      _$CalendarClassCopyWithImpl<$Res, CalendarClass>;
  @useResult
  $Res call(
      {String title,
      int period,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class _$CalendarClassCopyWithImpl<$Res, $Val extends CalendarClass>
    implements $CalendarClassCopyWith<$Res> {
  _$CalendarClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? period = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$CalendarClassImplCopyWith<$Res>
    implements $CalendarClassCopyWith<$Res> {
  factory _$$CalendarClassImplCopyWith(
          _$CalendarClassImpl value, $Res Function(_$CalendarClassImpl) then) =
      __$$CalendarClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      int period,
      @DateTimeConverter() DateTime startAt,
      @DateTimeConverter() DateTime endAt});
}

/// @nodoc
class __$$CalendarClassImplCopyWithImpl<$Res>
    extends _$CalendarClassCopyWithImpl<$Res, _$CalendarClassImpl>
    implements _$$CalendarClassImplCopyWith<$Res> {
  __$$CalendarClassImplCopyWithImpl(
      _$CalendarClassImpl _value, $Res Function(_$CalendarClassImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? period = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(_$CalendarClassImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$CalendarClassImpl implements _CalendarClass {
  const _$CalendarClassImpl(
      {required this.title,
      required this.period,
      @DateTimeConverter() required this.startAt,
      @DateTimeConverter() required this.endAt});

  factory _$CalendarClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarClassImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarClassImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, period, startAt, endAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarClassImplCopyWith<_$CalendarClassImpl> get copyWith =>
      __$$CalendarClassImplCopyWithImpl<_$CalendarClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarClassImplToJson(
      this,
    );
  }
}

abstract class _CalendarClass implements CalendarClass {
  const factory _CalendarClass(
          {required final String title,
          required final int period,
          @DateTimeConverter() required final DateTime startAt,
          @DateTimeConverter() required final DateTime endAt}) =
      _$CalendarClassImpl;

  factory _CalendarClass.fromJson(Map<String, dynamic> json) =
      _$CalendarClassImpl.fromJson;

  @override
  String get title;
  @override
  int get period;
  @override
  @DateTimeConverter()
  DateTime get startAt;
  @override
  @DateTimeConverter()
  DateTime get endAt;
  @override
  @JsonKey(ignore: true)
  _$$CalendarClassImplCopyWith<_$CalendarClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
