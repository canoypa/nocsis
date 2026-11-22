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
        widget.controller.selection = _boxSelection(
          index,
          widget.controller.text,
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
    final position = selection.isValid ? selection.start : text.length;
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
          i < text.length ? text[i].trim() : '',
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

/// 空いた桁は空白で持つ
const _empty = ' ';

/// 今の桁の文字を選んでおくと、打てば置き換わり、Backspace ではその桁が消える
TextSelection _boxSelection(int index, String text) => index < text.length
    ? TextSelection(baseOffset: index, extentOffset: index + 1)
    : TextSelection.collapsed(offset: text.length);

/// 1マスに1桁。打つとその桁を書き換え、消すとその桁だけを空ける。全角の数字も受け付ける
class _CodeFormatter extends TextInputFormatter {
  static final _fullWidthDigit = RegExp('[０-９]');
  static final _nonDigit = RegExp('[^0-9]');

  static String _digits(String text) => text
      .replaceAllMapped(
        _fullWidthDigit,
        (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0xFEE0),
      )
      .replaceAll(_nonDigit, '');

  static TextEditingValue _value(List<String> slots, int index) {
    final text = slots.join().trimRight();
    return TextEditingValue(
      text: text,
      selection: _boxSelection(index.clamp(0, text.length), text),
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 変換中に書き換えると、IME が確定前の文字を見失う
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final old = oldValue.text;
    final next = newValue.text;
    final start = oldValue.selection.isValid
        ? oldValue.selection.start
        : old.length;
    final end = oldValue.selection.isValid
        ? oldValue.selection.end
        : old.length;
    final slots = old.split('');
    final before = old.substring(0, start);
    final after = old.substring(end);

    if (next.length < old.length) {
      // 1マスを選んだまま消した
      if (end - start == 1 && next == before + after) {
        if (old[start] != _empty) {
          slots[start] = _empty;
          return _value(slots, start);
        }
        if (start == 0) return _value(slots, 0);
        slots[start - 1] = _empty;
        return _value(slots, start - 1);
      }
      // 末尾の空いたマスで Backspace
      if (start == end &&
          start > 0 &&
          next == old.substring(0, start - 1) + after) {
        slots[start - 1] = _empty;
        return _value(slots, start - 1);
      }
      if (start != end && next == before + after) {
        for (var i = start; i < end; i++) {
          slots[i] = _empty;
        }
        return _value(slots, start);
      }
    } else if (next.startsWith(before) && next.endsWith(after)) {
      final typed = _digits(next.substring(start, next.length - after.length));
      if (typed.isEmpty) return oldValue;

      for (var i = 0; i < typed.length; i++) {
        final index = start + i;
        if (index >= CodeField.length) break;
        if (index < slots.length) {
          slots[index] = typed[i];
        } else {
          slots.add(typed[i]);
        }
      }
      return _value(slots, start + typed.length);
    }

    // 判別できない書き換えは、数字だけを前から詰める
    var digits = _digits(next);
    if (digits.length > CodeField.length) {
      digits = digits.substring(0, CodeField.length);
    }
    return _value(digits.split(''), digits.length);
  }
}
