import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis/themes/app.dart';

ThemeData _base = darkTheme;

ThemeData createDisplayTheme(BuildContext context) {
  final theme = Theme.of(context);

  return _base.copyWith(
    textTheme: theme.textTheme.apply(fontSizeFactor: 3.sp),
  );
}
