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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyEventList _$MonthlyEventListFromJson(Map<String, dynamic> json) {
  return _MonthlyEventList.fromJson(json);
}

/// @nodoc
mixin _$MonthlyEventList {
  List<MonthEventList> get items => throw _privateConstructorUsedError;

  /// Serializes this MonthlyEventList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyEventList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyEventListCopyWith<MonthlyEventList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyEventListCopyWith<$Res> {
  factory $MonthlyEventListCopyWith(
    MonthlyEventList value,
    $Res Function(MonthlyEventList) then,
  ) = _$MonthlyEventListCopyWithImpl<$Res, MonthlyEventList>;
  @useResult
  $Res call({List<MonthEventList> items});
}

/// @nodoc
class _$MonthlyEventListCopyWithImpl<$Res, $Val extends MonthlyEventList>
    implements $MonthlyEventListCopyWith<$Res> {
  _$MonthlyEventListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyEventList
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
                        as List<MonthEventList>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyEventListImplCopyWith<$Res>
    implements $MonthlyEventListCopyWith<$Res> {
  factory _$$MonthlyEventListImplCopyWith(
    _$MonthlyEventListImpl value,
    $Res Function(_$MonthlyEventListImpl) then,
  ) = __$$MonthlyEventListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MonthEventList> items});
}

/// @nodoc
class __$$MonthlyEventListImplCopyWithImpl<$Res>
    extends _$MonthlyEventListCopyWithImpl<$Res, _$MonthlyEventListImpl>
    implements _$$MonthlyEventListImplCopyWith<$Res> {
  __$$MonthlyEventListImplCopyWithImpl(
    _$MonthlyEventListImpl _value,
    $Res Function(_$MonthlyEventListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyEventList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? items = null}) {
    return _then(
      _$MonthlyEventListImpl(
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<MonthEventList>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyEventListImpl implements _MonthlyEventList {
  const _$MonthlyEventListImpl({required final List<MonthEventList> items})
    : _items = items;

  factory _$MonthlyEventListImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyEventListImplFromJson(json);

  final List<MonthEventList> _items;
  @override
  List<MonthEventList> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthlyEventList(items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyEventListImpl &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  /// Create a copy of MonthlyEventList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyEventListImplCopyWith<_$MonthlyEventListImpl> get copyWith =>
      __$$MonthlyEventListImplCopyWithImpl<_$MonthlyEventListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyEventListImplToJson(this);
  }
}

abstract class _MonthlyEventList implements MonthlyEventList {
  const factory _MonthlyEventList({required final List<MonthEventList> items}) =
      _$MonthlyEventListImpl;

  factory _MonthlyEventList.fromJson(Map<String, dynamic> json) =
      _$MonthlyEventListImpl.fromJson;

  @override
  List<MonthEventList> get items;

  /// Create a copy of MonthlyEventList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyEventListImplCopyWith<_$MonthlyEventListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthEventList _$MonthEventListFromJson(Map<String, dynamic> json) {
  return _MonthEventList.fromJson(json);
}

/// @nodoc
mixin _$MonthEventList {
  String get month => throw _privateConstructorUsedError;
  List<EventData> get items => throw _privateConstructorUsedError;

  /// Serializes this MonthEventList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthEventList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthEventListCopyWith<MonthEventList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthEventListCopyWith<$Res> {
  factory $MonthEventListCopyWith(
    MonthEventList value,
    $Res Function(MonthEventList) then,
  ) = _$MonthEventListCopyWithImpl<$Res, MonthEventList>;
  @useResult
  $Res call({String month, List<EventData> items});
}

/// @nodoc
class _$MonthEventListCopyWithImpl<$Res, $Val extends MonthEventList>
    implements $MonthEventListCopyWith<$Res> {
  _$MonthEventListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthEventList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            month:
                null == month
                    ? _value.month
                    : month // ignore: cast_nullable_to_non_nullable
                        as String,
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<EventData>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthEventListImplCopyWith<$Res>
    implements $MonthEventListCopyWith<$Res> {
  factory _$$MonthEventListImplCopyWith(
    _$MonthEventListImpl value,
    $Res Function(_$MonthEventListImpl) then,
  ) = __$$MonthEventListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, List<EventData> items});
}

/// @nodoc
class __$$MonthEventListImplCopyWithImpl<$Res>
    extends _$MonthEventListCopyWithImpl<$Res, _$MonthEventListImpl>
    implements _$$MonthEventListImplCopyWith<$Res> {
  __$$MonthEventListImplCopyWithImpl(
    _$MonthEventListImpl _value,
    $Res Function(_$MonthEventListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthEventList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? items = null}) {
    return _then(
      _$MonthEventListImpl(
        month:
            null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                    as String,
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<EventData>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthEventListImpl implements _MonthEventList {
  const _$MonthEventListImpl({
    required this.month,
    required final List<EventData> items,
  }) : _items = items;

  factory _$MonthEventListImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthEventListImplFromJson(json);

  @override
  final String month;
  final List<EventData> _items;
  @override
  List<EventData> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MonthEventList(month: $month, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthEventListImpl &&
            (identical(other.month, month) || other.month == month) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    month,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of MonthEventList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthEventListImplCopyWith<_$MonthEventListImpl> get copyWith =>
      __$$MonthEventListImplCopyWithImpl<_$MonthEventListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthEventListImplToJson(this);
  }
}

abstract class _MonthEventList implements MonthEventList {
  const factory _MonthEventList({
    required final String month,
    required final List<EventData> items,
  }) = _$MonthEventListImpl;

  factory _MonthEventList.fromJson(Map<String, dynamic> json) =
      _$MonthEventListImpl.fromJson;

  @override
  String get month;
  @override
  List<EventData> get items;

  /// Create a copy of MonthEventList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthEventListImplCopyWith<_$MonthEventListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
