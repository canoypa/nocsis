import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _createTheme({
  required ThemeMode mode,
}) {
  final base = ThemeData(
    colorSchemeSeed: const Color(0x005c6bc0),
    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
  );

  return base.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme),
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
