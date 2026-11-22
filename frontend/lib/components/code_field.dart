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
    _focusNode.addListener(_redraw);
    widget.controller.addListener(_redraw);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_redraw);
    _focusNode.dispose();
    super.dispose();
  }

  void _redraw() => setState(() {});

  /// 押したマスの桁から打ち直せるようにする
  void _moveTo(double x) {
    var left = 0.0;
    var index = CodeField.length - 1;
    for (var i = 0; i < CodeField.length; i++) {
      if (i > 0) left += i == 3 ? CodeField._groupGap : CodeField._gap;
      if (x < left + CodeField._boxWidth) {
        index = i;
        break;
      }
      left += CodeField._boxWidth;
    }

    _focusNode.requestFocus();
    // 入力欄が自分のタップで置いた位置を、あとから上書きする
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        widget.controller.selection = TextSelection.collapsed(
          offset: index.clamp(0, widget.controller.text.length),
        );
      })
      ..scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.controller.text;
    final hasError = widget.errorText != null;
    final selection = widget.controller.selection;
    final position = selection.isValid ? selection.baseOffset : text.length;
    // 6桁そろって末尾にいるときは、次に打てるマスが無い
    final current = _focusNode.hasFocus && position < CodeField.length
        ? position
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
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerUp: (event) => _moveTo(event.localPosition.dx),
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    showCursor: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_CodeFormatter()],
                    onChanged: widget.onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'コード',
                    ),
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

/// 全角の数字も受け付け、途中の桁で打つとその桁を書き換える
class _CodeFormatter extends TextInputFormatter {
  static final _fullWidthDigit = RegExp('[０-９]');
  static final _nonDigit = RegExp('[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 変換中に書き換えると、IME が確定前の文字を見失う
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    String digits(String text) => text
        .replaceAllMapped(
          _fullWidthDigit,
          (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0xFEE0),
        )
        .replaceAll(_nonDigit, '');

    final old = oldValue.text;
    final start = oldValue.selection.isValid
        ? oldValue.selection.start
        : old.length;
    final end = oldValue.selection.isValid
        ? oldValue.selection.end
        : old.length;
    final before = old.substring(0, start);
    final after = old.substring(end);

    // 消したときや、何かを選んで置き換えたときは、そのまま詰める
    if (newValue.text.length <= old.length - (end - start) ||
        !newValue.text.startsWith(before) ||
        !newValue.text.endsWith(after)) {
      final text = digits(newValue.text);
      final clipped = text.length > CodeField.length
          ? text.substring(0, CodeField.length)
          : text;
      final offset = digits(
        newValue.text.substring(
          0,
          newValue.selection.isValid
              ? newValue.selection.baseOffset.clamp(0, newValue.text.length)
              : newValue.text.length,
        ),
      ).length.clamp(0, clipped.length);
      return TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: offset),
      );
    }

    final typed = digits(
      newValue.text.substring(start, newValue.text.length - after.length),
    );
    final rest = after.length > typed.length
        ? after.substring(typed.length)
        : '';
    var text = before + typed + rest;
    if (text.length > CodeField.length) {
      text = text.substring(0, CodeField.length);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: (start + typed.length).clamp(0, text.length),
      ),
    );
  }
}
