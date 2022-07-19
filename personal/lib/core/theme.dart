import 'package:flutter/material.dart';

ThemeData _createTheme({
  required ThemeMode mode,
}) {
  return ThemeData(
    // テーマ
    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
    // フォントに Noto Sans JP を使用
    fontFamily: "Noto Sans JP",

    // Material 3
    useMaterial3: true,
    colorSchemeSeed: const Color(0x005c6bc0),
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
