// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Weather _$WeatherFromJson(Map<String, dynamic> json) {
  return _Weather.fromJson(json);
}

/// @nodoc
mixin _$Weather {
  WeatherCurrent get current => throw _privateConstructorUsedError;
  WeatherHourly get hourly => throw _privateConstructorUsedError;
  List<String> get threeHour => throw _privateConstructorUsedError;

  /// Serializes this Weather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCopyWith<Weather> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCopyWith<$Res> {
  factory $WeatherCopyWith(Weather value, $Res Function(Weather) then) =
      _$WeatherCopyWithImpl<$Res, Weather>;
  @useResult
  $Res call({
    WeatherCurrent current,
    WeatherHourly hourly,
    List<String> threeHour,
  });

  $WeatherCurrentCopyWith<$Res> get current;
  $WeatherHourlyCopyWith<$Res> get hourly;
}

/// @nodoc
class _$WeatherCopyWithImpl<$Res, $Val extends Weather>
    implements $WeatherCopyWith<$Res> {
  _$WeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? hourly = null,
    Object? threeHour = null,
  }) {
    return _then(
      _value.copyWith(
            current:
                null == current
                    ? _value.current
                    : current // ignore: cast_nullable_to_non_nullable
                        as WeatherCurrent,
            hourly:
                null == hourly
                    ? _value.hourly
                    : hourly // ignore: cast_nullable_to_non_nullable
                        as WeatherHourly,
            threeHour:
                null == threeHour
                    ? _value.threeHour
                    : threeHour // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherCurrentCopyWith<$Res> get current {
    return $WeatherCurrentCopyWith<$Res>(_value.current, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherHourlyCopyWith<$Res> get hourly {
    return $WeatherHourlyCopyWith<$Res>(_value.hourly, (value) {
      return _then(_value.copyWith(hourly: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherImplCopyWith<$Res> implements $WeatherCopyWith<$Res> {
  factory _$$WeatherImplCopyWith(
    _$WeatherImpl value,
    $Res Function(_$WeatherImpl) then,
  ) = __$$WeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    WeatherCurrent current,
    WeatherHourly hourly,
    List<String> threeHour,
  });

  @override
  $WeatherCurrentCopyWith<$Res> get current;
  @override
  $WeatherHourlyCopyWith<$Res> get hourly;
}

/// @nodoc
class __$$WeatherImplCopyWithImpl<$Res>
    extends _$WeatherCopyWithImpl<$Res, _$WeatherImpl>
    implements _$$WeatherImplCopyWith<$Res> {
  __$$WeatherImplCopyWithImpl(
    _$WeatherImpl _value,
    $Res Function(_$WeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? hourly = null,
    Object? threeHour = null,
  }) {
    return _then(
      _$WeatherImpl(
        current:
            null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                    as WeatherCurrent,
        hourly:
            null == hourly
                ? _value.hourly
                : hourly // ignore: cast_nullable_to_non_nullable
                    as WeatherHourly,
        threeHour:
            null == threeHour
                ? _value._threeHour
                : threeHour // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherImpl implements _Weather {
  const _$WeatherImpl({
    required this.current,
    required this.hourly,
    required final List<String> threeHour,
  }) : _threeHour = threeHour;

  factory _$WeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherImplFromJson(json);

  @override
  final WeatherCurrent current;
  @override
  final WeatherHourly hourly;
  final List<String> _threeHour;
  @override
  List<String> get threeHour {
    if (_threeHour is EqualUnmodifiableListView) return _threeHour;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_threeHour);
  }

  @override
  String toString() {
    return 'Weather(current: $current, hourly: $hourly, threeHour: $threeHour)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.hourly, hourly) || other.hourly == hourly) &&
            const DeepCollectionEquality().equals(
              other._threeHour,
              _threeHour,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    current,
    hourly,
    const DeepCollectionEquality().hash(_threeHour),
  );

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      __$$WeatherImplCopyWithImpl<_$WeatherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherImplToJson(this);
  }
}

abstract class _Weather implements Weather {
  const factory _Weather({
    required final WeatherCurrent current,
    required final WeatherHourly hourly,
    required final List<String> threeHour,
  }) = _$WeatherImpl;

  factory _Weather.fromJson(Map<String, dynamic> json) = _$WeatherImpl.fromJson;

  @override
  WeatherCurrent get current;
  @override
  WeatherHourly get hourly;
  @override
  List<String> get threeHour;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherCurrent _$WeatherCurrentFromJson(Map<String, dynamic> json) {
  return _WeatherCurrent.fromJson(json);
}

/// @nodoc
mixin _$WeatherCurrent {
  String get name => throw _privateConstructorUsedError;
  int get temp => throw _privateConstructorUsedError;

  /// Serializes this WeatherCurrent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCurrentCopyWith<WeatherCurrent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCurrentCopyWith<$Res> {
  factory $WeatherCurrentCopyWith(
    WeatherCurrent value,
    $Res Function(WeatherCurrent) then,
  ) = _$WeatherCurrentCopyWithImpl<$Res, WeatherCurrent>;
  @useResult
  $Res call({String name, int temp});
}

/// @nodoc
class _$WeatherCurrentCopyWithImpl<$Res, $Val extends WeatherCurrent>
    implements $WeatherCurrentCopyWith<$Res> {
  _$WeatherCurrentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? temp = null}) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            temp:
                null == temp
                    ? _value.temp
                    : temp // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherCurrentImplCopyWith<$Res>
    implements $WeatherCurrentCopyWith<$Res> {
  factory _$$WeatherCurrentImplCopyWith(
    _$WeatherCurrentImpl value,
    $Res Function(_$WeatherCurrentImpl) then,
  ) = __$$WeatherCurrentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int temp});
}

/// @nodoc
class __$$WeatherCurrentImplCopyWithImpl<$Res>
    extends _$WeatherCurrentCopyWithImpl<$Res, _$WeatherCurrentImpl>
    implements _$$WeatherCurrentImplCopyWith<$Res> {
  __$$WeatherCurrentImplCopyWithImpl(
    _$WeatherCurrentImpl _value,
    $Res Function(_$WeatherCurrentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? temp = null}) {
    return _then(
      _$WeatherCurrentImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        temp:
            null == temp
                ? _value.temp
                : temp // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherCurrentImpl implements _WeatherCurrent {
  const _$WeatherCurrentImpl({required this.name, required this.temp});

  factory _$WeatherCurrentImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherCurrentImplFromJson(json);

  @override
  final String name;
  @override
  final int temp;

  @override
  String toString() {
    return 'WeatherCurrent(name: $name, temp: $temp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherCurrentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.temp, temp) || other.temp == temp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, temp);

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherCurrentImplCopyWith<_$WeatherCurrentImpl> get copyWith =>
      __$$WeatherCurrentImplCopyWithImpl<_$WeatherCurrentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherCurrentImplToJson(this);
  }
}

abstract class _WeatherCurrent implements WeatherCurrent {
  const factory _WeatherCurrent({
    required final String name,
    required final int temp,
  }) = _$WeatherCurrentImpl;

  factory _WeatherCurrent.fromJson(Map<String, dynamic> json) =
      _$WeatherCurrentImpl.fromJson;

  @override
  String get name;
  @override
  int get temp;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherCurrentImplCopyWith<_$WeatherCurrentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherHourly _$WeatherHourlyFromJson(Map<String, dynamic> json) {
  return _WeatherHourly.fromJson(json);
}

/// @nodoc
mixin _$WeatherHourly {
  List<num> get temp => throw _privateConstructorUsedError;
  List<num> get pop => throw _privateConstructorUsedError;

  /// Serializes this WeatherHourly to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherHourly
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherHourlyCopyWith<WeatherHourly> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherHourlyCopyWith<$Res> {
  factory $WeatherHourlyCopyWith(
    WeatherHourly value,
    $Res Function(WeatherHourly) then,
  ) = _$WeatherHourlyCopyWithImpl<$Res, WeatherHourly>;
  @useResult
  $Res call({List<num> temp, List<num> pop});
}

/// @nodoc
class _$WeatherHourlyCopyWithImpl<$Res, $Val extends WeatherHourly>
    implements $WeatherHourlyCopyWith<$Res> {
  _$WeatherHourlyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherHourly
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? temp = null, Object? pop = null}) {
    return _then(
      _value.copyWith(
            temp:
                null == temp
                    ? _value.temp
                    : temp // ignore: cast_nullable_to_non_nullable
                        as List<num>,
            pop:
                null == pop
                    ? _value.pop
                    : pop // ignore: cast_nullable_to_non_nullable
                        as List<num>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherHourlyImplCopyWith<$Res>
    implements $WeatherHourlyCopyWith<$Res> {
  factory _$$WeatherHourlyImplCopyWith(
    _$WeatherHourlyImpl value,
    $Res Function(_$WeatherHourlyImpl) then,
  ) = __$$WeatherHourlyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<num> temp, List<num> pop});
}

/// @nodoc
class __$$WeatherHourlyImplCopyWithImpl<$Res>
    extends _$WeatherHourlyCopyWithImpl<$Res, _$WeatherHourlyImpl>
    implements _$$WeatherHourlyImplCopyWith<$Res> {
  __$$WeatherHourlyImplCopyWithImpl(
    _$WeatherHourlyImpl _value,
    $Res Function(_$WeatherHourlyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherHourly
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? temp = null, Object? pop = null}) {
    return _then(
      _$WeatherHourlyImpl(
        temp:
            null == temp
                ? _value._temp
                : temp // ignore: cast_nullable_to_non_nullable
                    as List<num>,
        pop:
            null == pop
                ? _value._pop
                : pop // ignore: cast_nullable_to_non_nullable
                    as List<num>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherHourlyImpl implements _WeatherHourly {
  const _$WeatherHourlyImpl({
    required final List<num> temp,
    required final List<num> pop,
  }) : _temp = temp,
       _pop = pop;

  factory _$WeatherHourlyImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherHourlyImplFromJson(json);

  final List<num> _temp;
  @override
  List<num> get temp {
    if (_temp is EqualUnmodifiableListView) return _temp;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_temp);
  }

  final List<num> _pop;
  @override
  List<num> get pop {
    if (_pop is EqualUnmodifiableListView) return _pop;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pop);
  }

  @override
  String toString() {
    return 'WeatherHourly(temp: $temp, pop: $pop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherHourlyImpl &&
            const DeepCollectionEquality().equals(other._temp, _temp) &&
            const DeepCollectionEquality().equals(other._pop, _pop));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_temp),
    const DeepCollectionEquality().hash(_pop),
  );

  /// Create a copy of WeatherHourly
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherHourlyImplCopyWith<_$WeatherHourlyImpl> get copyWith =>
      __$$WeatherHourlyImplCopyWithImpl<_$WeatherHourlyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherHourlyImplToJson(this);
  }
}

abstract class _WeatherHourly implements WeatherHourly {
  const factory _WeatherHourly({
    required final List<num> temp,
    required final List<num> pop,
  }) = _$WeatherHourlyImpl;

  factory _WeatherHourly.fromJson(Map<String, dynamic> json) =
      _$WeatherHourlyImpl.fromJson;

  @override
  List<num> get temp;
  @override
  List<num> get pop;

  /// Create a copy of WeatherHourly
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherHourlyImplCopyWith<_$WeatherHourlyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
