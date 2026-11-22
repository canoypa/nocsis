import 'package:material_ui/material_ui.dart';
import 'package:nocsis/core/window_size_class.dart';

/// 狭い幅ではボタンを次の行に回す
class ActionRow extends StatelessWidget {
  final Widget content;
  final Widget action;

  const ActionRow({super.key, required this.content, required this.action});

  @override
  Widget build(BuildContext context) {
    if (context.windowSizeClass < .medium) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [content, action],
      );
    }
    return Row(
      spacing: 16,
      children: [
        Expanded(child: content),
        action,
      ],
    );
  }
}
