import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/routes/router.dart';

void main() {
  testWidgets('未ログインで保護ページを開くとログイン画面へ直接遷移する', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        '/groups/test-group/console';

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(MockFirebaseAuth(signedIn: false)),
      ],
    );

    addTearDown(container.dispose);
    addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );

    expect(find.text('管理コンソール'), findsNothing);

    await tester.pump();

    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.toString(),
      startsWith('/login?continue-uri='),
    );
    expect(find.text('ログイン'), findsWidgets);
    expect(find.text('Google で続行'), findsOneWidget);
    expect(find.text('管理コンソール'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('ログイン'), findsWidgets);
    expect(find.text('Google で続行'), findsOneWidget);
    expect(find.text('管理コンソール'), findsNothing);
  });
}