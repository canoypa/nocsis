// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
      _$CalendarEventListCopyWithImpl<$Res, CalendarEventList>;
  @useResult
  $Res call({bool isEmpty, List<CalendarEvent> items});
}

/// @nodoc
class _$CalendarEventListCopyWithImpl<$Res, $Val extends CalendarEventList>
    implements $CalendarEventListCopyWith<$Res> {
  _$CalendarEventListCopyWithImpl(this._value, this._then);

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
              as List<CalendarEvent>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventListImplCopyWith<$Res>
    implements $CalendarEventListCopyWith<$Res> {
  factory _$$CalendarEventListImplCopyWith(_$CalendarEventListImpl value,
          $Res Function(_$CalendarEventListImpl) then) =
      __$$CalendarEventListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isEmpty, List<CalendarEvent> items});
}

/// @nodoc
class __$$CalendarEventListImplCopyWithImpl<$Res>
    extends _$CalendarEventListCopyWithImpl<$Res, _$CalendarEventListImpl>
    implements _$$CalendarEventListImplCopyWith<$Res> {
  __$$CalendarEventListImplCopyWithImpl(_$CalendarEventListImpl _value,
      $Res Function(_$CalendarEventListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEmpty = null,
    Object? items = null,
  }) {
    return _then(_$CalendarEventListImpl(
      isEmpty: null == isEmpty
          ? _value.isEmpty
          : isEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CalendarEvent>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventListImpl implements _CalendarEventList {
  const _$CalendarEventListImpl(
      {required this.isEmpty, required final List<CalendarEvent> items})
      : _items = items;

  factory _$CalendarEventListImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventListImplFromJson(json);

  @override
  final bool isEmpty;
  final List<CalendarEvent> _items;
  @override
  List<CalendarEvent> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CalendarEventList(isEmpty: $isEmpty, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventListImpl &&
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
  _$$CalendarEventListImplCopyWith<_$CalendarEventListImpl> get copyWith =>
      __$$CalendarEventListImplCopyWithImpl<_$CalendarEventListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventListImplToJson(
      this,
    );
  }
}

abstract class _CalendarEventList implements CalendarEventList {
  const factory _CalendarEventList(
      {required final bool isEmpty,
      required final List<CalendarEvent> items}) = _$CalendarEventListImpl;

  factory _CalendarEventList.fromJson(Map<String, dynamic> json) =
      _$CalendarEventListImpl.fromJson;

  @override
  bool get isEmpty;
  @override
  List<CalendarEvent> get items;
  @override
  @JsonKey(ignore: true)
  _$$CalendarEventListImplCopyWith<_$CalendarEventListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
