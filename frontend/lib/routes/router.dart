import 'dart:async';

import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/core/route_access.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/pages/classroom.dart';
import 'package:nocsis/pages/console/calendar.dart';
import 'package:nocsis/pages/console/dayduty.dart';
import 'package:nocsis/pages/console/displays/page.dart';
import 'package:nocsis/pages/console/group.dart';
import 'package:nocsis/pages/console/index.dart';
import 'package:nocsis/pages/console/layout.dart';
import 'package:nocsis/pages/console/members.dart';
import 'package:nocsis/pages/console/slack.dart';
import 'package:nocsis/pages/console/weather.dart';
import 'package:nocsis/pages/display/pairing.dart';
import 'package:nocsis/pages/display/register.dart';
import 'package:nocsis/pages/group/group_layout.dart';
import 'package:nocsis/pages/licenses.dart';
import 'package:nocsis/pages/login.dart';
import 'package:nocsis/pages/main/events/page.dart';
import 'package:nocsis/pages/main/home/page.dart';
import 'package:nocsis/pages/main/layout.dart';
import 'package:nocsis/pages/no_group.dart';
import 'package:nocsis/pages/not_found.dart';
import 'package:nocsis/pages/settings/index.dart';
import 'package:nocsis/pages/settings/layout.dart';
import 'package:nocsis/providers/auth.dart';
import 'package:nocsis/providers/current_group_id.dart';
import 'package:nocsis/providers/firebase.dart';
import 'package:nocsis/providers/me.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'classroom_page_route.dart';
part 'console/console_calendar_page_route.dart';
part 'console/console_day_duty_page_route.dart';
part 'console/console_displays_page_route.dart';
part 'console/console_group_page_route.dart';
part 'console/console_member_page_route.dart';
part 'console/console_shell_route.dart';
part 'console/console_slack_page_route.dart';
part 'console/console_top_page_route.dart';
part 'console/console_weather_page_route.dart';
part 'display_page_route.dart';
part 'group/group_shell_route.dart';
part 'licenses_page_route.dart';
part 'login_page_route.dart';
part 'personal/personal_events_page_route.dart';
part 'personal/personal_home_page_route.dart';
part 'personal/personal_shell_route.dart';
part 'router.g.dart';
part 'settings/settings_shell_route.dart';
part 'settings/settings_top_page_route.dart';
part 'top_page_route.dart';

@TypedShellRoute<AppShell>(
  routes: [
    displayPageRoute,
    displayRegisterPageRoute,
    groupShellRoute,
    licensesPageRoute,
    loginPageRoute,
    topPageRoute,
  ],
)
class AppShell extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }
}

/// redirect から投げると、go_router が URL をそのままにエラー画面を出す
class _PageNotFound implements Exception {
  const _PageNotFound();
}

class _RouterRefresher extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

@riverpod
GoRouter router(Ref ref) {
  final refresher = _RouterRefresher();
  ref.listen(authProvider, (_, _) => refresher.refresh());

  // 読む画面が無いと meProvider は取得中に破棄され得るので、読み終わるまで購読しておく
  Future<Me> readMe(String uid) async {
    final subscription = ref.listen(meProvider(uid), (_, _) {});
    try {
      return await ref.read(meProvider(uid).future);
    } finally {
      subscription.close();
    }
  }

  Future<String?> redirectFromTopPage(Uri uri) async {
    if (uri.path != '/') {
      return null;
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    final groupId = sharedPreferences.getString('latest_group_id');

    if (groupId != null) {
      return uri.path == '/'
          ? "/groups/$groupId"
          : "/groups/$groupId${uri.path}";
    }

    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) {
      return null;
    }

    final me = await readMe(uid);
    if (me.memberships.isEmpty) {
      // 登録が解除された端末は、また登録を待つ画面に戻す
      final isAnonymous =
          ref.read(firebaseAuthProvider).currentUser?.isAnonymous ?? false;
      return isAnonymous ? DisplayPageRoute.path : null;
    }

    final firstGroupId = me.memberships.first.group.id;

    sharedPreferences.setString('latest_group_id', firstGroupId);

    return uri.path == '/'
        ? "/groups/$firstGroupId"
        : "/groups/$firstGroupId${uri.path}";
  }

  Future<String?> redirectNotLoggedInUser(GoRouterState state) async {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    final sharedPreferences = await SharedPreferences.getInstance();

    if (currentUser != null) {
      if (!currentUser.isAnonymous) {
        await sharedPreferences.remove(displayDeviceKey);
      }
      return null;
    }

    if (isPublic(state.fullPath ?? '')) {
      return null;
    }

    // 登録を解除された端末はアカウントごと消え、サインアウトされる。ログイン画面に
    // 出しても教室には操作する人がいないので、また登録を待つ画面に戻す
    if (sharedPreferences.getBool(displayDeviceKey) ?? false) {
      return DisplayPageRoute.path;
    }

    final continueUri = state.uri.toString() == "/" ? null : state.uri;
    return LoginPageRoute(continueUri: continueUri).location;
  }

  Future<String?> redirectLoggedInUser(GoRouterState state) async {
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    // 端末の匿名アカウントのままでも、人のアカウントでログインし直せるようにする
    final isLoggedIn = currentUser != null && !currentUser.isAnonymous;

    if (!isLoggedIn || state.matchedLocation != LoginPageRoute().location) {
      return null;
    }

    final continueUri = Uri.tryParse(
      state.uri.queryParameters["continue-uri"] ?? "/",
    );

    if (continueUri == null) {
      return "/";
    }

    return await redirectFromTopPage(continueUri) ?? continueUri.toString();
  }

  /// [routeAccess] の宣言を満たさないルートは、URL を変えずにその場で 404 を出す
  Future<String?> redirectByAccess(GoRouterState state) async {
    final path = state.fullPath;
    // どのルートにも当たらない URL は go_router のエラー画面が出す
    if (path == null) {
      return null;
    }

    if (declarationsFor(path).isEmpty) {
      throw const _PageNotFound();
    }

    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final groupId = state.pathParameters['groupId'];
    if (!needsGroupPermissions(path) || uid == null || groupId == null) {
      return null;
    }

    try {
      var granted = permissionsIn(await readMe(uid), groupId);

      if (!canOpen(path, granted)) {
        // 後からグループに追加された直後かもしれないので、一度だけ取り直す
        ref.invalidate(meProvider(uid));
        granted = permissionsIn(await readMe(uid), groupId);
      }

      if (canOpen(path, granted)) {
        return null;
      }
    } catch (_) {
      // 取れないときは通す。止めても守れるもの（画面の API はサーバが判定する）は無く、
      // 止めると教室の画面が通信の回復を待てない。次の遷移で取り直す
      ref.invalidate(meProvider(uid));
      return null;
    }

    // 開けないグループを覚えていると、トップからまたそこへ飛ばされ続ける
    final sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('latest_group_id') == groupId) {
      await sharedPreferences.remove('latest_group_id');
    }

    if (ref.read(firebaseAuthProvider).currentUser?.isAnonymous ?? false) {
      return DisplayPageRoute.path;
    }

    // 権限が無いことと、グループの存在を区別しない
    throw const _PageNotFound();
  }

  return GoRouter(
    routes: $appRoutes,
    refreshListenable: refresher,
    // redirect で投げた例外もここに来る。どれも開けるページが無いという意味なので 404 に寄せる
    errorBuilder: (context, state) => const ErrorPage(),
    redirect: (context, state) async {
      return await redirectNotLoggedInUser(state) ??
          await redirectLoggedInUser(state) ??
          await redirectFromTopPage(state.uri) ??
          await redirectByAccess(state);
    },
  );
}
