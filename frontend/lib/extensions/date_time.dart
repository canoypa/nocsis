extension JstDateTime on DateTime {
  /// 日本時間の暦の上の日時。端末のタイムゾーンによらず同じ日付になる
  DateTime toJst() => toUtc().add(const Duration(hours: 9));
}
