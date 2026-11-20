import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/account_menu.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/me.dart';

void main() {
  Future<void> openMenu(WidgetTester tester, Set<Permission> granted) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          groupPermissionsProvider('g1').overrideWith((ref) async => granted),
          authProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: Scaffold(body: AccountMenu())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
  }

  testWidgets('group.update を持つ相手には管理コンソールを出す', (tester) async {
    await openMenu(tester, {Permission.groupRead, Permission.groupUpdate});

    expect(find.text('管理コンソール'), findsOneWidget);
  });

  testWidgets('閲覧だけの相手には管理コンソールを出さない', (tester) async {
    await openMenu(tester, {Permission.groupRead, Permission.memberRead});

    expect(find.text('管理コンソール'), findsNothing);
    expect(find.text('Classroom を起動'), findsOneWidget);
  });
}
