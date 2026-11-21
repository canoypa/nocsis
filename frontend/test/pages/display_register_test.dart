import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nocsis/generated/api_client/api.enums.swagger.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/display/register.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/me.dart';

import '../helpers/mock_api_client.dart';

void main() {
  late MockApi mockApi;

  setUpAll(() {
    registerFallbackValue(const DisplayCreateJson(code: '', name: ''));
  });

  Future<void> pumpPage(WidgetTester tester, int status) async {
    mockApi = MockApi();
    when(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: any(named: 'groupId'),
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async => chopper.Response(http.Response('', status), null),
    );

    final router = GoRouter(
      initialLocation: '/display/register',
      routes: [
        GoRoute(
          path: '/display/register',
          builder: (_, _) => const DisplayRegisterPage(code: '482913'),
        ),
        GoRoute(
          path: '/groups/:groupId/console/displays',
          builder: (_, state) => Text('一覧 ${state.pathParameters['groupId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWith((ref) async => mockApi),
          currentUidProvider.overrideWithValue('u1'),
          meProvider('u1').overrideWith(
            (ref) async => const Me(
              memberships: [
                Membership(
                  group: MembershipGroup(id: 'viewer', name: '閲覧だけ'),
                  permissions: [Permission.groupRead],
                ),
                Membership(
                  group: MembershipGroup(id: 'g1', name: '1年1組'),
                  permissions: [Permission.accessCreate],
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '名前'), '黒板横');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '登録'));
    await tester.pumpAndSettle();
  }

  testWidgets('登録できるグループに、読み取ったコードで登録して一覧へ移る', (tester) async {
    await pumpPage(tester, 201);

    verify(
      () => mockApi.apiV1GroupsGroupIdDisplaysPost(
        groupId: 'g1',
        body: const DisplayCreateJson(code: '482913', name: '黒板横'),
      ),
    ).called(1);
    expect(find.text('一覧 g1'), findsOneWidget);
  });

  testWidgets('期限が切れていれば、読み取り直すよう出す', (tester) async {
    await pumpPage(tester, 404);

    expect(
      find.text('コードの期限が切れています。ディスプレイの QR コードを読み取り直してください。'),
      findsOneWidget,
    );
  });
}
