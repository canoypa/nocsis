import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _baseTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorSchemeSeed: const Color(0x006750a4),
);

ThemeData createAppTheme(BuildContext context) {
  final theme = Theme.of(context);

  return _baseTheme.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(theme.textTheme
        .merge(_baseTheme.textTheme)
        .apply(fontSizeFactor: 3.sp)),
  );
}
