import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

extension GapExtension on Iterable<Widget> {
  List<Widget> gap(double value) => expand((item) sync* {
        yield Gap(value);
        yield item;
      }).skip(1).toList();
}
