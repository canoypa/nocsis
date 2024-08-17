import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis_classroom/core/theme.dart';
import 'package:nocsis_classroom/screens/home.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(
          child: ScreenUtilInit(
            designSize: const Size(960, 540),
            builder: (context, child) {
              final theme = createDisplayTheme(context);

              return Theme(
                data: theme,
                child: const Scaffold(
                  body: HomeScreen(),
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
