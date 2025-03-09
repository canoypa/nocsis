import 'package:freezed_annotation/freezed_annotation.dart';

part 'daydudy.freezed.dart';
part 'daydudy.g.dart';

@freezed
abstract class Daydudy with _$Daydudy {
  const factory Daydudy({
    required String firstName,
    required String lastName,
    required int stuNo,
  }) = _Daydudy;

  factory Daydudy.fromJson(Map<String, dynamic> json) =>
      _$DaydudyFromJson(json);
}
