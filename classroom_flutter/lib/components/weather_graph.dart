import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/models/weather.dart';
import 'package:nocsis_classroom/providers/weather.dart';

class WeatherGraph extends ConsumerWidget {
  const WeatherGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider).maybeWhen(
          data: (data) => data.hourly,
          orElse: () => const WeatherHourly(temp: [0, 0], pop: [0, 0]),
        );

    final tempData = weatherData.temp;
    final tempMax = tempData.reduce(max);
    final tempMin = tempData.reduce(min);

    final popData = weatherData.pop;

    final temp = tempData.asMap().entries.map((e) {
      return Offset(
        e.key / (tempData.length - 1),
        (e.value - tempMin) / (tempMax - tempMin),
      );
    }).toList();
    final pop = popData.asMap().entries.map((e) {
      return Offset(
        e.key / (popData.length - 1),
        e.value.toDouble(),
      );
    }).toList();

    return SizedBox.expand(
      child: CustomPaint(
        painter: _WeatherGraphPainter(temp: temp, pop: pop),
      ),
    );
  }
}

class _WeatherGraphPainter extends CustomPainter {
  static const _tempColor = Color(0xFFFFD54F);

  static const _popColor = Color(0xFF64B5F6);

  static final _tempFillPaint = Paint()..color = _tempColor.withAlpha(51);

  static final _tempLinePaint = Paint()
    ..color = _tempColor
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  static final _popFillPaint = Paint()..color = _popColor.withAlpha(51);

  static final _popLinePaint = Paint()
    ..color = _popColor
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;

  final List<Offset> temp;
  final List<Offset> pop;

  _WeatherGraphPainter({required this.temp, required this.pop});

  @override
  void paint(Canvas canvas, Size size) {
    // 表示範囲は全体で 50%、それぞれ 25% とする

    final tempOffsets = temp.map((v) {
      return Offset(
        v.dx * size.width,
        size.height - v.dy * size.height * 0.25,
      );
    }).toList();

    final popOffsets = pop.map((v) {
      return Offset(
        v.dx * size.width,
        size.height - v.dy * size.height * 0.25,
      );
    }).toList();

    final tempLinePath = Path();

    tempLinePath.moveTo(
        tempOffsets[0].dx, tempOffsets[0].dy - size.height * 0.25);

    for (var v in tempOffsets) {
      tempLinePath.lineTo(v.dx, v.dy - size.height * 0.25);
    }

    final tempFillPath = Path();

    tempFillPath.moveTo(tempOffsets[0].dx, tempOffsets[0].dy);

    for (var v in tempOffsets) {
      tempFillPath.lineTo(v.dx, v.dy - size.height * 0.25);
    }

    // 降水確率のグラフに被らないようにする

    for (var v in popOffsets.reversed) {
      tempFillPath.lineTo(v.dx, v.dy);
    }

    tempFillPath.close();

    final popLinePath = Path();

    popLinePath.moveTo(popOffsets[0].dx, popOffsets[0].dy);

    for (var v in popOffsets) {
      popLinePath.lineTo(v.dx, v.dy);
    }

    final popFillPath = Path();

    popFillPath.moveTo(popOffsets[0].dx, popOffsets[0].dy);

    for (var v in popOffsets) {
      popFillPath.lineTo(v.dx, v.dy);
    }

    popFillPath.lineTo(size.width, size.height);

    popFillPath.lineTo(0, size.height);

    popFillPath.close();

    canvas.drawPath(tempFillPath, _WeatherGraphPainter._tempFillPaint);

    canvas.drawPath(tempLinePath, _WeatherGraphPainter._tempLinePaint);

    canvas.drawPath(popFillPath, _WeatherGraphPainter._popFillPaint);

    canvas.drawPath(popLinePath, _WeatherGraphPainter._popLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
