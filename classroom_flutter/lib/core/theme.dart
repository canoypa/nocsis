import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData _baseTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorSchemeSeed: const Color(0x006750a4),
);

ThemeData createAppTheme(BuildContext context) {
  return _baseTheme.copyWith(
    textTheme: Theme.of(context)
        .textTheme
        .merge(_baseTheme.textTheme)
        .apply(fontSizeFactor: 1.sp),
  );
}
