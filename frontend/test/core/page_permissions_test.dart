import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/core/page_permissions.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';

void main() {
  // backend の roles.ts と同じ束。ロールを変えたらここも見直す
  const viewer = {Permission.groupRead};
  const display = {Permission.groupRead, Permission.memberRead};
  final admin = Permission.values.toSet();

  test('閲覧だけのロールは、コンソールも教室の画面も開けない', () {
    for (final route in pagePermissions.keys) {
      expect(canOpenPage(route, viewer), isFalse, reason: route);
    }
  });

  test('教室の表示端末のロールは、教室の画面だけを開ける', () {
    for (final route in pagePermissions.keys) {
      expect(canOpenPage(route, display), route == '/classroom', reason: route);
    }
  });

  test('admin はすべての画面を開ける', () {
    for (final route in pagePermissions.keys) {
      expect(canOpenPage(route, admin), isTrue, reason: route);
    }
  });

  test('定義に無い画面は開けない', () {
    expect(canOpenPage('/unknown', admin), isFalse);
  });
}
