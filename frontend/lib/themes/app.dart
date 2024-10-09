import 'package:flutter/material.dart';

ThemeData _createTheme({
  required ThemeMode mode,
}) {
  return ThemeData(
    fontFamily: 'NotoSansJP',
    colorSchemeSeed: const Color(0x005c6bc0),
    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
