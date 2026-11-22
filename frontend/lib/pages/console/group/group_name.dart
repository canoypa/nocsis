import 'package:flutter/widgets.dart';

bool isValidGroupName(String name) {
  final trimmed = name.trim();
  return trimmed.isNotEmpty && trimmed.characters.length <= 50;
}
