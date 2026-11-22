import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

ThemeData _createTheme({required ThemeMode mode}) {
  final buttonStyle = ButtonStyle(
    minimumSize: WidgetStateProperty.all(const Size(0, 44)),
  );

  final base = ThemeData(
    colorSchemeSeed: const Color(0x005c6bc0),
    brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
    textButtonTheme: TextButtonThemeData(style: buttonStyle),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const Icon(Symbols.arrow_back),
      closeButtonIconBuilder: (_) => const Icon(Symbols.close),
      drawerButtonIconBuilder: (_) => const Icon(Symbols.menu),
      endDrawerButtonIconBuilder: (_) => const Icon(Symbols.menu),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme),
  );
}

final ThemeData lightTheme = _createTheme(mode: ThemeMode.light);
final ThemeData darkTheme = _createTheme(mode: ThemeMode.dark);
