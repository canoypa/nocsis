// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClassList _$ClassListFromJson(Map<String, dynamic> json) {
  return _ClassList.fromJson(json);
}

/// @nodoc
mixin _$ClassList {
  List<ClassData> get items => throw _privateConstructorUsedError;

  /// Serializes this ClassList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassListCopyWith<ClassList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassListCopyWith<$Res> {
  factory $ClassListCopyWith(ClassList value, $Res Function(ClassList) then) =
      _$ClassListCopyWithImpl<$Res, ClassList>;
  @useResult
  $Res call({List<ClassData> items});
}

/// @nodoc
class _$ClassListCopyWithImpl<$Res, $Val extends ClassList>
    implements $ClassListCopyWith<$Res> {
  _$ClassListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _value.copyWith(
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<ClassData>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassListImplCopyWith<$Res>
    implements $ClassListCopyWith<$Res> {
  factory _$$ClassListImplCopyWith(
    _$ClassListImpl value,
    $Res Function(_$ClassListImpl) then,
  ) = __$$ClassListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ClassData> items});
}

/// @nodoc
class __$$ClassListImplCopyWithImpl<$Res>
    extends _$ClassListCopyWithImpl<$Res, _$ClassListImpl>
    implements _$$ClassListImplCopyWith<$Res> {
  __$$ClassListImplCopyWithImpl(
    _$ClassListImpl _value,
    $Res Function(_$ClassListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$ClassListImpl(
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<ClassData>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassListImpl implements _ClassList {
  const _$ClassListImpl({required final List<ClassData> items})
    : _items = items;

  factory _$ClassListImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassListImplFromJson(json);

  final List<ClassData> _items;
  @override
  List<ClassData> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ClassList(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassListImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of ClassList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassListImplCopyWith<_$ClassListImpl> get copyWith =>
      __$$ClassListImplCopyWithImpl<_$ClassListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassListImplToJson(this);
  }
}

abstract class _ClassList implements ClassList {
  const factory _ClassList({required final List<ClassData> items}) =
      _$ClassListImpl;

  factory _ClassList.fromJson(Map<String, dynamic> json) =
      _$ClassListImpl.fromJson;

  @override
  List<ClassData> get items;

  /// Create a copy of ClassList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassListImplCopyWith<_$ClassListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassData _$ClassDataFromJson(Map<String, dynamic> json) {
  return _ClassData.fromJson(json);
}

/// @nodoc
mixin _$ClassData {
  String get title => throw _privateConstructorUsedError;
  int get period => throw _privateConstructorUsedError;
  @LocalDateTimeConverter()
  DateTime get startAt => throw _privateConstructorUsedError;
  @LocalDateTimeConverter()
  DateTime get endAt => throw _privateConstructorUsedError;

  /// Serializes this ClassData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassDataCopyWith<ClassData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassDataCopyWith<$Res> {
  factory $ClassDataCopyWith(ClassData value, $Res Function(ClassData) then) =
      _$ClassDataCopyWithImpl<$Res, ClassData>;
  @useResult
  $Res call({
    String title,
    int period,
    @LocalDateTimeConverter() DateTime startAt,
    @LocalDateTimeConverter() DateTime endAt,
  });
}

/// @nodoc
class _$ClassDataCopyWithImpl<$Res, $Val extends ClassData>
    implements $ClassDataCopyWith<$Res> {
  _$ClassDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? period = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(
      _value.copyWith(
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            period:
                null == period
                    ? _value.period
                    : period // ignore: cast_nullable_to_non_nullable
                        as int,
            startAt:
                null == startAt
                    ? _value.startAt
                    : startAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endAt:
                null == endAt
                    ? _value.endAt
                    : endAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassDataImplCopyWith<$Res>
    implements $ClassDataCopyWith<$Res> {
  factory _$$ClassDataImplCopyWith(
    _$ClassDataImpl value,
    $Res Function(_$ClassDataImpl) then,
  ) = __$$ClassDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    int period,
    @LocalDateTimeConverter() DateTime startAt,
    @LocalDateTimeConverter() DateTime endAt,
  });
}

/// @nodoc
class __$$ClassDataImplCopyWithImpl<$Res>
    extends _$ClassDataCopyWithImpl<$Res, _$ClassDataImpl>
    implements _$$ClassDataImplCopyWith<$Res> {
  __$$ClassDataImplCopyWithImpl(
    _$ClassDataImpl _value,
    $Res Function(_$ClassDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? period = null,
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(
      _$ClassDataImpl(
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        period:
            null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                    as int,
        startAt:
            null == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endAt:
            null == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassDataImpl implements _ClassData {
  const _$ClassDataImpl({
    required this.title,
    required this.period,
    @LocalDateTimeConverter() required this.startAt,
    @LocalDateTimeConverter() required this.endAt,
  });

  factory _$ClassDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassDataImplFromJson(json);

  @override
  final String title;
  @override
  final int period;
  @override
  @LocalDateTimeConverter()
  final DateTime startAt;
  @override
  @LocalDateTimeConverter()
  final DateTime endAt;

  @override
  String toString() {
    return 'ClassData(title: $title, period: $period, startAt: $startAt, endAt: $endAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, period, startAt, endAt);

  /// Create a copy of ClassData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassDataImplCopyWith<_$ClassDataImpl> get copyWith =>
      __$$ClassDataImplCopyWithImpl<_$ClassDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassDataImplToJson(this);
  }
}

abstract class _ClassData implements ClassData {
  const factory _ClassData({
    required final String title,
    required final int period,
    @LocalDateTimeConverter() required final DateTime startAt,
    @LocalDateTimeConverter() required final DateTime endAt,
  }) = _$ClassDataImpl;

  factory _ClassData.fromJson(Map<String, dynamic> json) =
      _$ClassDataImpl.fromJson;

  @override
  String get title;
  @override
  int get period;
  @override
  @LocalDateTimeConverter()
  DateTime get startAt;
  @override
  @LocalDateTimeConverter()
  DateTime get endAt;

  /// Create a copy of ClassData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassDataImplCopyWith<_$ClassDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
