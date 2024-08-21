import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _base = ThemeData(
  colorSchemeSeed: const Color(0x006750a4),
  brightness: Brightness.dark,
);

ThemeData createDisplayTheme(BuildContext context) {
  final theme = Theme.of(context);

  return _base.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(
      theme.textTheme.merge(_base.textTheme).apply(fontSizeFactor: 3.sp),
    ),
  );
}