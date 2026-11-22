import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// 入力欄は1つのまま、見た目だけ6マスに描く。貼り付けや削除を普通の入力欄のまま扱える
class CodeField extends StatefulWidget {
  static const length = 6;
  static const _boxWidth = 56.0;
  static const _gap = 8.0;
  static const _groupGap = 24.0;
  static const width = _boxWidth * length + _gap * (length - 2) + _groupGap;

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const CodeField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.controller.text;
    final hasError = widget.errorText != null;
    final current = _focusNode.hasFocus
        ? text.length.clamp(0, CodeField.length - 1)
        : null;

    Widget box(int i) {
      final isCurrent = i == current;
      final color = hasError
          ? colorScheme.error
          : isCurrent
          ? colorScheme.primary
          : colorScheme.outline;

      return Container(
        width: CodeField._boxWidth,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: isCurrent ? 2 : 1),
        ),
        child: Text(
          i < text.length ? text[i] : '',
          style: textTheme.headlineMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < CodeField.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: i == 3 ? CodeField._groupGap : CodeField._gap,
                    ),
                  box(i),
                ],
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  showCursor: false,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(CodeField.length),
                  ],
                  onChanged: widget.onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'コード',
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
      ],
    );
  }
}
