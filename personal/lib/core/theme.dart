import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _createTheme({
  required ThemeMode mode,
}) {
  final baseTheme = ThemeData(
    // Material 3
    useMaterial3: true,
    colorSchemeSeed: const Color(0x005c6bc0),

    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme),
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
