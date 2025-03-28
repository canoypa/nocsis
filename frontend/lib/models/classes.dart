import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nocsis/converters/local_date_time.dart';

part 'classes.freezed.dart';
part 'classes.g.dart';

@freezed
abstract class ClassList with _$ClassList {
  const factory ClassList({required List<ClassData> items}) = _ClassList;

  factory ClassList.fromJson(Map<String, dynamic> json) =>
      _$ClassListFromJson(json);
}

@freezed
abstract class ClassData with _$ClassData {
  const factory ClassData({
    required String title,
    required int period,
    @LocalDateTimeConverter() required DateTime startAt,
    @LocalDateTimeConverter() required DateTime endAt,
  }) = _ClassData;

  factory ClassData.fromJson(Map<String, dynamic> json) =>
      _$ClassDataFromJson(json);
}
