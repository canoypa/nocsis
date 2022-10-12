import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis_classroom/screens/home.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(560, 315),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        ThemeData baseTheme = ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: const Color(0x006750a4),
        );

        ThemeData appTheme = baseTheme.copyWith(
          textTheme: Theme.of(context)
              .textTheme
              .merge(baseTheme.textTheme)
              .apply(fontSizeFactor: 1.sp),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nocsis',
          theme: appTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}
