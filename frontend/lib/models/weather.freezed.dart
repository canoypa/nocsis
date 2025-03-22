// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Weather {

 WeatherCurrent get current; WeatherHourly get hourly; List<String> get threeHour;
/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherCopyWith<Weather> get copyWith => _$WeatherCopyWithImpl<Weather>(this as Weather, _$identity);

  /// Serializes this Weather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Weather&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly)&&const DeepCollectionEquality().equals(other.threeHour, threeHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,hourly,const DeepCollectionEquality().hash(threeHour));

@override
String toString() {
  return 'Weather(current: $current, hourly: $hourly, threeHour: $threeHour)';
}


}

/// @nodoc
abstract mixin class $WeatherCopyWith<$Res>  {
  factory $WeatherCopyWith(Weather value, $Res Function(Weather) _then) = _$WeatherCopyWithImpl;
@useResult
$Res call({
 WeatherCurrent current, WeatherHourly hourly, List<String> threeHour
});


$WeatherCurrentCopyWith<$Res> get current;$WeatherHourlyCopyWith<$Res> get hourly;

}
/// @nodoc
class _$WeatherCopyWithImpl<$Res>
    implements $WeatherCopyWith<$Res> {
  _$WeatherCopyWithImpl(this._self, this._then);

  final Weather _self;
  final $Res Function(Weather) _then;

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? hourly = null,Object? threeHour = null,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as WeatherCurrent,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as WeatherHourly,threeHour: null == threeHour ? _self.threeHour : threeHour // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherCurrentCopyWith<$Res> get current {
  
  return $WeatherCurrentCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherHourlyCopyWith<$Res> get hourly {
  
  return $WeatherHourlyCopyWith<$Res>(_self.hourly, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Weather implements Weather {
  const _Weather({required this.current, required this.hourly, required final  List<String> threeHour}): _threeHour = threeHour;
  factory _Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);

@override final  WeatherCurrent current;
@override final  WeatherHourly hourly;
 final  List<String> _threeHour;
@override List<String> get threeHour {
  if (_threeHour is EqualUnmodifiableListView) return _threeHour;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_threeHour);
}


/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherCopyWith<_Weather> get copyWith => __$WeatherCopyWithImpl<_Weather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Weather&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly)&&const DeepCollectionEquality().equals(other._threeHour, _threeHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,hourly,const DeepCollectionEquality().hash(_threeHour));

@override
String toString() {
  return 'Weather(current: $current, hourly: $hourly, threeHour: $threeHour)';
}


}

/// @nodoc
abstract mixin class _$WeatherCopyWith<$Res> implements $WeatherCopyWith<$Res> {
  factory _$WeatherCopyWith(_Weather value, $Res Function(_Weather) _then) = __$WeatherCopyWithImpl;
@override @useResult
$Res call({
 WeatherCurrent current, WeatherHourly hourly, List<String> threeHour
});


@override $WeatherCurrentCopyWith<$Res> get current;@override $WeatherHourlyCopyWith<$Res> get hourly;

}
/// @nodoc
class __$WeatherCopyWithImpl<$Res>
    implements _$WeatherCopyWith<$Res> {
  __$WeatherCopyWithImpl(this._self, this._then);

  final _Weather _self;
  final $Res Function(_Weather) _then;

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? hourly = null,Object? threeHour = null,}) {
  return _then(_Weather(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as WeatherCurrent,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as WeatherHourly,threeHour: null == threeHour ? _self._threeHour : threeHour // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherCurrentCopyWith<$Res> get current {
  
  return $WeatherCurrentCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of Weather
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherHourlyCopyWith<$Res> get hourly {
  
  return $WeatherHourlyCopyWith<$Res>(_self.hourly, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}
}


/// @nodoc
mixin _$WeatherCurrent {

 String get name; int get temp;
/// Create a copy of WeatherCurrent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherCurrentCopyWith<WeatherCurrent> get copyWith => _$WeatherCurrentCopyWithImpl<WeatherCurrent>(this as WeatherCurrent, _$identity);

  /// Serializes this WeatherCurrent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherCurrent&&(identical(other.name, name) || other.name == name)&&(identical(other.temp, temp) || other.temp == temp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,temp);

@override
String toString() {
  return 'WeatherCurrent(name: $name, temp: $temp)';
}


}

/// @nodoc
abstract mixin class $WeatherCurrentCopyWith<$Res>  {
  factory $WeatherCurrentCopyWith(WeatherCurrent value, $Res Function(WeatherCurrent) _then) = _$WeatherCurrentCopyWithImpl;
@useResult
$Res call({
 String name, int temp
});




}
/// @nodoc
class _$WeatherCurrentCopyWithImpl<$Res>
    implements $WeatherCurrentCopyWith<$Res> {
  _$WeatherCurrentCopyWithImpl(this._self, this._then);

  final WeatherCurrent _self;
  final $Res Function(WeatherCurrent) _then;

/// Create a copy of WeatherCurrent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? temp = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _WeatherCurrent implements WeatherCurrent {
  const _WeatherCurrent({required this.name, required this.temp});
  factory _WeatherCurrent.fromJson(Map<String, dynamic> json) => _$WeatherCurrentFromJson(json);

@override final  String name;
@override final  int temp;

/// Create a copy of WeatherCurrent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherCurrentCopyWith<_WeatherCurrent> get copyWith => __$WeatherCurrentCopyWithImpl<_WeatherCurrent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherCurrentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherCurrent&&(identical(other.name, name) || other.name == name)&&(identical(other.temp, temp) || other.temp == temp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,temp);

@override
String toString() {
  return 'WeatherCurrent(name: $name, temp: $temp)';
}


}

/// @nodoc
abstract mixin class _$WeatherCurrentCopyWith<$Res> implements $WeatherCurrentCopyWith<$Res> {
  factory _$WeatherCurrentCopyWith(_WeatherCurrent value, $Res Function(_WeatherCurrent) _then) = __$WeatherCurrentCopyWithImpl;
@override @useResult
$Res call({
 String name, int temp
});




}
/// @nodoc
class __$WeatherCurrentCopyWithImpl<$Res>
    implements _$WeatherCurrentCopyWith<$Res> {
  __$WeatherCurrentCopyWithImpl(this._self, this._then);

  final _WeatherCurrent _self;
  final $Res Function(_WeatherCurrent) _then;

/// Create a copy of WeatherCurrent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? temp = null,}) {
  return _then(_WeatherCurrent(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WeatherHourly {

 List<num> get temp; List<num> get pop;
/// Create a copy of WeatherHourly
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherHourlyCopyWith<WeatherHourly> get copyWith => _$WeatherHourlyCopyWithImpl<WeatherHourly>(this as WeatherHourly, _$identity);

  /// Serializes this WeatherHourly to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherHourly&&const DeepCollectionEquality().equals(other.temp, temp)&&const DeepCollectionEquality().equals(other.pop, pop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(temp),const DeepCollectionEquality().hash(pop));

@override
String toString() {
  return 'WeatherHourly(temp: $temp, pop: $pop)';
}


}

/// @nodoc
abstract mixin class $WeatherHourlyCopyWith<$Res>  {
  factory $WeatherHourlyCopyWith(WeatherHourly value, $Res Function(WeatherHourly) _then) = _$WeatherHourlyCopyWithImpl;
@useResult
$Res call({
 List<num> temp, List<num> pop
});




}
/// @nodoc
class _$WeatherHourlyCopyWithImpl<$Res>
    implements $WeatherHourlyCopyWith<$Res> {
  _$WeatherHourlyCopyWithImpl(this._self, this._then);

  final WeatherHourly _self;
  final $Res Function(WeatherHourly) _then;

/// Create a copy of WeatherHourly
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temp = null,Object? pop = null,}) {
  return _then(_self.copyWith(
temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as List<num>,pop: null == pop ? _self.pop : pop // ignore: cast_nullable_to_non_nullable
as List<num>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _WeatherHourly implements WeatherHourly {
  const _WeatherHourly({required final  List<num> temp, required final  List<num> pop}): _temp = temp,_pop = pop;
  factory _WeatherHourly.fromJson(Map<String, dynamic> json) => _$WeatherHourlyFromJson(json);

 final  List<num> _temp;
@override List<num> get temp {
  if (_temp is EqualUnmodifiableListView) return _temp;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_temp);
}

 final  List<num> _pop;
@override List<num> get pop {
  if (_pop is EqualUnmodifiableListView) return _pop;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pop);
}


/// Create a copy of WeatherHourly
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherHourlyCopyWith<_WeatherHourly> get copyWith => __$WeatherHourlyCopyWithImpl<_WeatherHourly>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherHourlyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherHourly&&const DeepCollectionEquality().equals(other._temp, _temp)&&const DeepCollectionEquality().equals(other._pop, _pop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_temp),const DeepCollectionEquality().hash(_pop));

@override
String toString() {
  return 'WeatherHourly(temp: $temp, pop: $pop)';
}


}

/// @nodoc
abstract mixin class _$WeatherHourlyCopyWith<$Res> implements $WeatherHourlyCopyWith<$Res> {
  factory _$WeatherHourlyCopyWith(_WeatherHourly value, $Res Function(_WeatherHourly) _then) = __$WeatherHourlyCopyWithImpl;
@override @useResult
$Res call({
 List<num> temp, List<num> pop
});




}
/// @nodoc
class __$WeatherHourlyCopyWithImpl<$Res>
    implements _$WeatherHourlyCopyWith<$Res> {
  __$WeatherHourlyCopyWithImpl(this._self, this._then);

  final _WeatherHourly _self;
  final $Res Function(_WeatherHourly) _then;

/// Create a copy of WeatherHourly
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temp = null,Object? pop = null,}) {
  return _then(_WeatherHourly(
temp: null == temp ? _self._temp : temp // ignore: cast_nullable_to_non_nullable
as List<num>,pop: null == pop ? _self._pop : pop // ignore: cast_nullable_to_non_nullable
as List<num>,
  ));
}


}

// dart format on
