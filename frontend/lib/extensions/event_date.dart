import 'package:nocsis/generated/api_client/api.models.swagger.dart';

extension EventStartDate on Event {
  /// 終日の予定は暦の日付、時刻のある予定は端末の日時
  DateTime get startDate => start.date ?? start.dateTime!.toLocal();
}
