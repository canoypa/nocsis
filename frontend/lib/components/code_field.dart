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
  final VoidCallback? onSubmitted;

  const CodeField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  static const _empty = ' ';
  static final _fullWidthDigit = RegExp('[０-９]');
  static final _nonDigit = RegExp('[^0-9]');

  late final _focusNode = FocusNode(onKeyEvent: _onKey);
  late final _formatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final value = _format(newValue);
    // 空いたマスで消したときは文字が変わらず、選んだマスだけが動く
    _redraw();
    return value;
  });

  /// 選んでいるマス
  var _index = 0;

  /// 狭い幅では、マスと間隔を同じ割合で縮める
  var _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _index = widget.controller.text.length.clamp(0, CodeField.length - 1);
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChange);
  }

  /// マスを押して入ってきたときは、押したマスを選ぶ
  var _pointerDown = false;

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_pointerDown) _index = _lastSelectable;
    _redraw();
  }

  void _onControllerChange() {
    final controller = widget.controller;
    final end = TextSelection.collapsed(offset: controller.text.length);
    // 入力欄のカーソルは末尾に置いたままにする。長押しや全選択で動いても戻す
    if (controller.selection != end) {
      controller.selection = end;
      return;
    }
    _redraw();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
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

    // 入力欄で変わった部分だけを取り出す
    var prefix = 0;
    while (prefix < committed.length &&
        prefix < next.length &&
        committed[prefix] == next[prefix]) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < committed.length - prefix &&
        suffix < next.length - prefix &&
        committed[committed.length - 1 - suffix] ==
            next[next.length - 1 - suffix]) {
      suffix++;
    }
    final inserted = next.substring(prefix, next.length - suffix);

    if (inserted.isEmpty) {
      if (next.length < committed.length) {
        // Backspace。空いたマスでは、前へ移るだけ
        slots[_index] = _empty;
        _index = (_index - 1).clamp(0, CodeField.length - 1);
      }
      return _valueOf(slots);
    }

    final digits = _digits(inserted);
    // 6桁ちょうどはコードそのものなので全体を置き換える。7桁以上はどの6桁か決められない
    if (digits.length == CodeField.length) {
      _index = CodeField.length - 1;
      return _valueOf(digits.split(''));
    }
    if (digits.isEmpty || digits.length > CodeField.length) {
      return _valueOf(slots);
    }

    for (final digit in digits.split('')) {
      slots[_index] = digit;
      if (_index == CodeField.length - 1) break;
      _index++;
    }
    return _valueOf(slots);
  }

  /// 空いたマスより先は選べない
  int get _lastSelectable =>
      widget.controller.text.length.clamp(0, CodeField.length - 1);

  /// 入力欄のカーソルは使わないので、カーソルを動かすキーと Delete はマスの操作に読み替える
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final int? index = switch (key) {
      LogicalKeyboardKey.arrowLeft => _index - 1,
      LogicalKeyboardKey.arrowRight => _index + 1,
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => _lastSelectable,
      _ => null,
    };
    if (index != null) {
      setState(() => _index = index.clamp(0, _lastSelectable));
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.delete) {
      final slots = _slots..[_index] = _empty;
      widget.controller.value = _valueOf(slots);
      widget.onChanged(widget.controller.text);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// 押したマスを選ぶ。まだ前に空いたマスがあれば、そこより先へは進めない
  void _select(double scaledX) {
    final x = scaledX / _scale;
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
    setState(() => _index = index.clamp(0, _lastSelectable));
    _pointerDown = false;
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
        width: CodeField._boxWidth * _scale,
        height: 64 * _scale,
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
      spacing: CodeField._gap * _scale,
      children: [for (var i = from; i < from + 3; i++) box(i)],
    );

    return Column(
      spacing: 8,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            _scale = (constraints.maxWidth / CodeField.width).clamp(0.0, 1.0);
            return Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: CodeField._groupGap * _scale,
                  children: [group(0), group(3)],
                ),
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (_) => _pointerDown = true,
                    onPointerUp: (event) => _select(event.localPosition.dx),
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        showCursor: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_formatter],
                        onChanged: widget.onChanged,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => widget.onSubmitted?.call(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'コード',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
