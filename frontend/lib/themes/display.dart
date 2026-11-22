import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nocsis/themes/app.dart';

ThemeData _base = darkTheme;

/// [textScale] は 960x540 を基準にした文字の倍率。遠くから読む教室の画面は大きくする
ThemeData createDisplayTheme(BuildContext context, {double textScale = 3}) {
  final theme = Theme.of(context);

  return _base.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(
      theme.textTheme
          .merge(_base.textTheme)
          .apply(fontSizeFactor: textScale.sp),
    ),
  );
}
