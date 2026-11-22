import 'package:analyzer/dart/element/type.dart';

/// frontend の lib/core/window_size_class.dart にある enum
bool isWindowSizeClass(DartType? type) {
  if (type is! InterfaceType) return false;
  final element = type.element;
  return element.name == 'WindowSizeClass' &&
      element.library.uri.toString() ==
          'package:nocsis/core/window_size_class.dart';
}
