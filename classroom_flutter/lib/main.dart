import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis_classroom/core/theme.dart';
import 'package:nocsis_classroom/screens/home.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540),
      builder: (context, child) {
        final appTheme = createAppTheme(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nocsis',
          theme: appTheme,
          home: child,
        );
      },
      child: const Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
