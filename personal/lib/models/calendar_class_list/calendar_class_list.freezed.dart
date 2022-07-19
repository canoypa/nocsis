// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'calendar_class_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CalendarClassList _$CalendarClassListFromJson(Map<String, dynamic> json) {
  return _CalendarClassList.fromJson(json);
}

/// @nodoc
mixin _$CalendarClassList {
  bool get isEmpty => throw _privateConstructorUsedError;
  List<CalendarClass> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarClassListCopyWith<CalendarClassList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarClassListCopyWith<$Res> {
  factory $CalendarClassListCopyWith(
          CalendarClassList value, $Res Function(CalendarClassList) then) =
      _$CalendarClassListCopyWithImpl<$Res>;
  $Res call({bool isEmpty, List<CalendarClass> items});
}

/// @nodoc
class _$CalendarClassListCopyWithImpl<$Res>
    implements $CalendarClassListCopyWith<$Res> {
  _$CalendarClassListCopyWithImpl(this._value, this._then);

  final CalendarClassList _value;
  // ignore: unused_field
  final $Res Function(CalendarClassList) _then;

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
              as List<CalendarClass>,
    ));
  }
}

/// @nodoc
abstract class _$CalendarClassListCopyWith<$Res>
    implements $CalendarClassListCopyWith<$Res> {
  factory _$CalendarClassListCopyWith(
          _CalendarClassList value, $Res Function(_CalendarClassList) then) =
      __$CalendarClassListCopyWithImpl<$Res>;
  @override
  $Res call({bool isEmpty, List<CalendarClass> items});
}

/// @nodoc
class __$CalendarClassListCopyWithImpl<$Res>
    extends _$CalendarClassListCopyWithImpl<$Res>
    implements _$CalendarClassListCopyWith<$Res> {
  __$CalendarClassListCopyWithImpl(
      _CalendarClassList _value, $Res Function(_CalendarClassList) _then)
      : super(_value, (v) => _then(v as _CalendarClassList));

  @override
  _CalendarClassList get _value => super._value as _CalendarClassList;

  @override
  $Res call({
    Object? isEmpty = freezed,
    Object? items = freezed,
  }) {
    return _then(_CalendarClassList(
      isEmpty: isEmpty == freezed
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: items == freezed
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarClass>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CalendarClassList implements _CalendarClassList {
  const _$_CalendarClassList(
      {required this.isEmpty, required final List<CalendarClass> items})
      : _items = items;

  factory _$_CalendarClassList.fromJson(Map<String, dynamic> json) =>
      _$$_CalendarClassListFromJson(json);

  @override
  final bool isEmpty;
  final List<CalendarClass> _items;
  @override
  List<CalendarClass> get items {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CalendarClassList(isEmpty: $isEmpty, items: $items)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CalendarClassList &&
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
  _$CalendarClassListCopyWith<_CalendarClassList> get copyWith =>
      __$CalendarClassListCopyWithImpl<_CalendarClassList>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CalendarClassListToJson(this);
  }
}

abstract class _CalendarClassList implements CalendarClassList {
  const factory _CalendarClassList(
      {required final bool isEmpty,
      required final List<CalendarClass> items}) = _$_CalendarClassList;

  factory _CalendarClassList.fromJson(Map<String, dynamic> json) =
      _$_CalendarClassList.fromJson;

  @override
  bool get isEmpty => throw _privateConstructorUsedError;
  @override
  List<CalendarClass> get items => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$CalendarClassListCopyWith<_CalendarClassList> get copyWith =>
      throw _privateConstructorUsedError;
}
