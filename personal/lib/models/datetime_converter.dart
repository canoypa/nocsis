import 'package:freezed_annotation/freezed_annotation.dart';

// デフォルトだと UTC になるので、toLocal を実行するよう上書きしたもの

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.parse(json).toLocal();
  }

  @override
  String toJson(DateTime object) {
    return object.toIso8601String();
  }
}
