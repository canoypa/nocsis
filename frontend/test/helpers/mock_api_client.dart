import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.swagger.dart';
import 'package:nocsis/providers/api_client.dart';

class MockApi extends Mock implements Api {}

// Riverpod の Override 型は internals 経由でのみ公開されており
// (flutter_riverpod のバレルからは export されない)、外部コードから
// 明示的に参照することを想定していない。戻り値型は推論に委ねる。
// ignore: strict_top_level_inference
overrideApiClient(Api api) {
  return apiClientProvider.overrideWith((ref) async => api);
}
