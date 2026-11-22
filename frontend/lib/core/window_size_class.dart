import 'package:material_ui/material_ui.dart';

/// Material 3 の window size class。境目は https://m3.material.io/foundations/layout/applying-layout/window-size-classes
///
/// large と extra-large を分けて使う画面がまだ無いので、1200 以上はまとめて large にしている。
enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large;

  factory WindowSizeClass.fromWidth(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    if (width < 1200) return expanded;
    return large;
  }

  factory WindowSizeClass.of(BuildContext context) =>
      WindowSizeClass.fromWidth(MediaQuery.sizeOf(context).width);

  bool operator <(WindowSizeClass other) => index < other.index;
  bool operator >=(WindowSizeClass other) => index >= other.index;
}
