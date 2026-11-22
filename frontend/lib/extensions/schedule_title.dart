import 'package:nocsis/generated/api_client/api.models.swagger.dart';

const _noTitle = '(No title)';

extension ClassTitle on Class {
  String get shownTitle => title.isEmpty ? _noTitle : title;
}

extension EventTitle on Event {
  String get shownTitle => title.isEmpty ? _noTitle : title;
}
