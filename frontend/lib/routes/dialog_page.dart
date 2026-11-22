import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/core/browser_history.dart';

/// ダイアログをルートのページとして開く。push すると履歴に積まれるので、ブラウザの戻るで閉じられる
class DialogPage<T> extends Page<T> {
  final WidgetBuilder builder;

  const DialogPage({super.key, required this.builder});

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) => PopScope(
        // バリアや Esc で閉じるときも、履歴を戻して閉じる
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) closeDialog(context);
        },
        child: builder(context),
      ),
    );
  }
}

/// pop で閉じると閉じた状態が新しい履歴として積まれ、ブラウザの戻るで開き直してしまう
void closeDialog(BuildContext context) {
  final pushed =
      GoRouter.of(context).routerDelegate.currentConfiguration.matches.last
          is ImperativeRouteMatch;
  // URL で直接開いたときは、戻る先がこのアプリの外かもしれない
  if (pushed && backInBrowserHistory()) return;
  Navigator.of(context).pop();
}
