// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_class_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
      _$CalendarClassListCopyWithImpl<$Res, CalendarClassList>;
  @useResult
  $Res call({bool isEmpty, List<CalendarClass> items});
}

/// @nodoc
class _$CalendarClassListCopyWithImpl<$Res, $Val extends CalendarClassList>
    implements $CalendarClassListCopyWith<$Res> {
  _$CalendarClassListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEmpty = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      isEmpty: null == isEmpty
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarClass>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarClassListImplCopyWith<$Res>
    implements $CalendarClassListCopyWith<$Res> {
  factory _$$CalendarClassListImplCopyWith(_$CalendarClassListImpl value,
          $Res Function(_$CalendarClassListImpl) then) =
      __$$CalendarClassListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isEmpty, List<CalendarClass> items});
}

/// @nodoc
class __$$CalendarClassListImplCopyWithImpl<$Res>
    extends _$CalendarClassListCopyWithImpl<$Res, _$CalendarClassListImpl>
    implements _$$CalendarClassListImplCopyWith<$Res> {
  __$$CalendarClassListImplCopyWithImpl(_$CalendarClassListImpl _value,
      $Res Function(_$CalendarClassListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEmpty = null,
    Object? items = null,
  }) {
    return _then(_$CalendarClassListImpl(
      isEmpty: null == isEmpty
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarClass>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarClassListImpl implements _CalendarClassList {
  const _$CalendarClassListImpl(
      {required this.isEmpty, required final List<CalendarClass> items})
      : _items = items;

  factory _$CalendarClassListImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarClassListImplFromJson(json);

  @override
  final bool isEmpty;
  final List<CalendarClass> _items;
  @override
  List<CalendarClass> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CalendarClassList(isEmpty: $isEmpty, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarClassListImpl &&
            (identical(other.isEmpty, isEmpty) || other.isEmpty == isEmpty) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, isEmpty, const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarClassListImplCopyWith<_$CalendarClassListImpl> get copyWith =>
      __$$CalendarClassListImplCopyWithImpl<_$CalendarClassListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarClassListImplToJson(
      this,
    );
  }
}

abstract class _CalendarClassList implements CalendarClassList {
  const factory _CalendarClassList(
      {required final bool isEmpty,
      required final List<CalendarClass> items}) = _$CalendarClassListImpl;

  factory _CalendarClassList.fromJson(Map<String, dynamic> json) =
      _$CalendarClassListImpl.fromJson;

  @override
  bool get isEmpty;
  @override
  List<CalendarClass> get items;
  @override
  @JsonKey(ignore: true)
  _$$CalendarClassListImplCopyWith<_$CalendarClassListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
