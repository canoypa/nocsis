import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// 入力欄は1つのまま、見た目だけ6マスに描く。貼り付けや IME を普通の入力欄のまま扱える
///
/// マスには普通の入力欄のような文字の間のカーソルが無く、いつもどれか1マスを選んでいる。
/// 打つと選んだマスの桁を書き換えて次へ進み、Backspace は選んだマスの桁を消して前へ戻る。
/// 後ろの桁は詰めない。空いた桁は空白で持つ
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
  static const _empty = ' ';
  static final _fullWidthDigit = RegExp('[０-９]');
  static final _nonDigit = RegExp('[^0-9]');

  final _focusNode = FocusNode();
  late final _formatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final value = _format(newValue);
    // 空いたマスで消したときは文字が変わらず、選んだマスだけが動く
    _redraw();
    return value;
  });

  /// 選んでいるマス
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.controller.text.length.clamp(0, CodeField.length - 1);
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

  static String _digits(String text) => text
      .replaceAllMapped(
        _fullWidthDigit,
        (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0xFEE0),
      )
      .replaceAll(_nonDigit, '');

  List<String> get _slots => [
    for (var i = 0; i < CodeField.length; i++)
      i < widget.controller.text.length ? widget.controller.text[i] : _empty,
  ];

  TextEditingValue _valueOf(List<String> slots) {
    final text = slots.join().trimRight();
    // 入力欄のカーソルはいつも末尾に置く。消す・打つの区別だけを入力欄から受け取る
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  TextEditingValue _format(TextEditingValue newValue) {
    // 変換中に書き換えると、IME が確定前の文字を見失う
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final slots = _slots;
    final committed = slots.join().trimRight();
    final next = newValue.text;

    if (next.length < committed.length && committed.startsWith(next)) {
      slots[_index] = _empty;
      _index = (_index - 1).clamp(0, CodeField.length - 1);
      return _valueOf(slots);
    }

    if (next.startsWith(committed)) {
      final typed = _digits(next.substring(committed.length));
      if (typed.isEmpty) return _valueOf(slots);

      for (final digit in typed.split('')) {
        slots[_index] = digit;
        if (_index == CodeField.length - 1) break;
        _index++;
      }
      return _valueOf(slots);
    }

    // 全部を選んで貼り付けたときなど。数字だけを前から詰める
    final digits = _digits(next);
    final filled = [
      for (var i = 0; i < CodeField.length; i++)
        i < digits.length ? digits[i] : _empty,
    ];
    _index = digits.length.clamp(0, CodeField.length - 1);
    return _valueOf(filled);
  }

  /// 押したマスを選ぶ。まだ前に空いたマスがあれば、そこより先へは進めない
  void _select(double x) {
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
    setState(() {
      _index = index.clamp(
        0,
        widget.controller.text.length.clamp(0, CodeField.length - 1),
      );
    });
    // 入力欄が自分のタップで置いたカーソルを、末尾に戻す
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        final text = widget.controller.text;
        widget.controller.selection = TextSelection.collapsed(
          offset: text.length,
        );
      })
      ..scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final slots = _slots;
    final hasError = widget.errorText != null;

    Widget box(int i) {
      final isCurrent = _focusNode.hasFocus && i == _index;
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
        child: Text(slots[i].trim(), style: textTheme.headlineMedium),
      );
    }

    Widget group(int from) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: CodeField._gap,
      children: [for (var i = from; i < from + 3; i++) box(i)],
    );

    return Column(
      spacing: 8,
      children: [
        Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: CodeField._groupGap,
              children: [group(0), group(3)],
            ),
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerUp: (event) => _select(event.localPosition.dx),
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_formatter],
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
          Text(
            widget.errorText!,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
      ],
    );
  }
}
