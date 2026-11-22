import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/providers/api_client.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:riverpod_annotation/experimental/scope.dart';

import '../helpers/fake_backend.dart';

const _classes = '/api/v1/groups/g1/classes';
const _events = '/api/v1/groups/g1/events';

Map<String, Object> _event(String title, DateTime startAt) => {
  'id': title,
  'title': title,
  'startAt': startAt.toUtc().toIso8601String(),
  'endAt': startAt.add(const Duration(hours: 1)).toUtc().toIso8601String(),
  'isAllDay': false,
};

String _twoDigitYear(int year) => (year % 100).toString().padLeft(2, '0');

@Dependencies([currentGroupId])
void main() {
  setUpAll(() => initializeDateFormatting('ja_JP'));

  Future<void> pump(
    WidgetTester tester,
    Widget page,
    Map<String, Object> responses,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentGroupIdProvider.overrideWithValue('g1'),
          apiClientProvider.overrideWith((ref) async => fakeBackend(responses)),
        ],
        retry: (_, _) => null,
        child: MaterialApp(home: Scaffold(body: page)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ホーム', () {
    testWidgets('その日の授業とイベントを出す', (tester) async {
      final today = DateTime.now();
      await pump(tester, const MainView(), {
        _classes: {
          'items': [
            {
              'title': '数学',
              'period': 2,
              'startAt': DateTime(
                today.year,
                today.month,
                today.day,
                10,
                40,
              ).toUtc().toIso8601String(),
              'endAt': DateTime(
                today.year,
                today.month,
                today.day,
                11,
                30,
              ).toUtc().toIso8601String(),
            },
          ],
        },
        _events: {
          'items': [_event('文化祭', today)],
        },
      });

      expect(find.text('数学'), findsOneWidget);
      expect(find.text('2限目'), findsOneWidget);
      expect(find.text('10:40-11:30'), findsOneWidget);
      expect(find.text('文化祭'), findsOneWidget);
    });

    testWidgets('授業がなくイベントだけの日は、イベントを出す', (tester) async {
      await pump(tester, const MainView(), {
        _classes: {'items': []},
        _events: {
          'items': [_event('文化祭', DateTime.now())],
        },
      });

      expect(find.text('文化祭'), findsOneWidget);
      expect(
        find.text(DateFormat('M月d日').format(DateTime.now())),
        findsOneWidget,
      );
      expect(find.text('予定なし'), findsNothing);
    });

    testWidgets('授業もイベントもない日は「予定なし」を出す', (tester) async {
      await pump(tester, const MainView(), {
        _classes: {'items': []},
        _events: {'items': []},
      });

      expect(find.text('予定なし'), findsOneWidget);
    });

    testWidgets('取得に失敗したら、失敗したことを出す', (tester) async {
      await pump(tester, const MainView(), {
        _classes: http.Response('', 500),
        _events: {'items': []},
      });

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('次の日へ進むと日付が変わり、前の日へ戻ると元の日付に戻る', (tester) async {
      await pump(tester, const MainView(), {
        _classes: {'items': []},
        _events: {'items': []},
      });
      final dateLabel = find.textContaining(RegExp(r'^\d+月\d+日 \(.\)$'));
      String shownDate() => tester.widget<Text>(dateLabel).data!;
      final today = shownDate();

      await tester.tap(find.byIcon(Icons.navigate_next));
      await tester.pumpAndSettle();
      expect(shownDate(), isNot(today));

      await tester.tap(find.byIcon(Icons.navigate_before));
      await tester.pumpAndSettle();
      expect(shownDate(), today);
    });
  });

  group('ホームの日付', () {
    testWidgets('日本時間の今日の日付を出す', (tester) async {
      await pump(tester, const MainView(), {
        _classes: {'items': []},
        _events: {'items': []},
      });
      final todayInJapan = DateTime.now().toUtc().add(const Duration(hours: 9));

      expect(
        find.text(DateFormat('M月d日 (E)', 'ja_JP').format(todayInJapan)),
        findsOneWidget,
      );
    });
  });

  group('イベント', () {
    testWidgets('これからのイベントを日付つきで出す', (tester) async {
      await pump(tester, const EventsView(), {
        _events: {
          'items': [
            _event('文化祭', DateTime(2030, 5, 20, 9)),
            _event('体育祭', DateTime(2030, 6, 3, 9)),
          ],
        },
      });

      expect(find.text('5月20日'), findsOneWidget);
      expect(find.text('文化祭'), findsOneWidget);
      expect(find.text('6月3日'), findsOneWidget);
      expect(find.text('体育祭'), findsOneWidget);
    });

    testWidgets('月の見出しは、今年の月なら年を省き、来年以降なら年を付ける', (tester) async {
      final now = DateTime.now();
      await pump(tester, const EventsView(), {
        _events: {
          'items': [
            _event('今年のイベント', DateTime(now.year, now.month, now.day, 23)),
            _event('来年のイベント', DateTime(now.year + 1, 5, 20, 9)),
          ],
        },
      });

      expect(find.text('${now.month}月'), findsOneWidget);
      expect(find.text('${_twoDigitYear(now.year + 1)}年5月'), findsOneWidget);
    });

    testWidgets('年が違えば、同じ月でも見出しを分ける', (tester) async {
      final nextYear = DateTime.now().year + 1;
      await pump(tester, const EventsView(), {
        _events: {
          'items': [
            _event('来年のイベント', DateTime(nextYear, 5, 20, 9)),
            _event('再来年のイベント', DateTime(nextYear + 1, 5, 20, 9)),
          ],
        },
      });

      expect(find.text('${_twoDigitYear(nextYear)}年5月'), findsOneWidget);
      expect(find.text('${_twoDigitYear(nextYear + 1)}年5月'), findsOneWidget);
    });

    testWidgets('イベントがなければ「予定なし」を出す', (tester) async {
      await pump(tester, const EventsView(), {
        _events: {'items': []},
      });

      expect(find.text('予定なし'), findsOneWidget);
    });

    testWidgets('取得に失敗したら、失敗したことを出す', (tester) async {
      await pump(tester, const EventsView(), {_events: http.Response('', 500)});

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
