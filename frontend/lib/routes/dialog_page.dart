import 'package:material_ui/material_ui.dart';

/// ダイアログをルートのページとして開く。push すると履歴に積まれるので、ブラウザの戻るで閉じられる
class DialogPage<T> extends Page<T> {
  final WidgetBuilder builder;

  const DialogPage({super.key, required this.builder});

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(context: context, settings: this, builder: builder);
  }
}
