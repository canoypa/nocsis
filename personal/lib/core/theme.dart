import 'package:flutter/material.dart';

final _baseTheme = ThemeData(
  // フォントに Noto Sans JP を使用
  fontFamily: "Noto Sans JP",

  // Material 3
  useMaterial3: true,
  colorSchemeSeed: const Color(0x005c6bc0),
);

ThemeData _createTheme({
  required ThemeMode mode,
}) {
  return _baseTheme.copyWith(
    // テーマ
    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
