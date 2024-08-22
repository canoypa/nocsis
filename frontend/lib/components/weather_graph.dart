import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/models/weather.dart';
import 'package:nocsis_classroom/providers/weather.dart';

class WeatherGraph extends ConsumerWidget {
  const WeatherGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider).value?.hourly ??
        WeatherHourly(
          temp: List.generate(9, (index) => 0),
          pop: List.generate(9, (index) => 0),
        );

    return SizedBox.expand(
      child: LayoutBuilder(builder: (context, constraints) {
        return _Canvas(
          constraints: constraints,
          temp: weather.temp,
          pop: weather.pop,
        );
      }),
    );
  }
}

class _Canvas extends ConsumerStatefulWidget {
  final BoxConstraints constraints;
  final List<num> temp;
  final List<num> pop;

  const _Canvas({
    required this.constraints,
    required this.temp,
    required this.pop,
  });

  @override
  _CanvasState createState() => _CanvasState();
}

class _CanvasState extends ConsumerState<_Canvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final CurvedAnimation _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);

  List<Tween<Offset>>? _tempTweens;
  List<Tween<Offset>>? _popTweens;

  @override
  void initState() {
    super.initState();

    _updateTweens();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Canvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateTweens();

    _controller
      ..reset()
      ..forward();
  }

  _updateTweens() {
    final width = widget.constraints.maxWidth;
    final height = widget.constraints.maxHeight;

    final tempMax = widget.temp.reduce(max);
    final tempMin = widget.temp.reduce(min);
    final tempRange = tempMax - tempMin;
    final isInitial = widget.temp.every((e) => e == 0);

    _tempTweens = widget.temp.mapIndexed<Tween<Offset>>((i, e) {
      final h = (e - tempMin) / (tempRange == 0 ? 1 : tempRange);
      final target = Offset(
        i / (widget.temp.length - 1) * width,
        height - (h * height * 0.25 + (isInitial ? 0 : height * 0.25)),
      );

      return Tween(
        begin: _tempTweens?[i].evaluate(_animation) ?? target,
        end: target,
      );
    }).toList();
    _popTweens = widget.pop.mapIndexed<Tween<Offset>>((i, e) {
      final target = Offset(
        i / (widget.pop.length - 1) * width,
        height - e.toDouble() * (height * 0.25),
      );
      return Tween(
        begin: _popTweens?[i].evaluate(_animation) ?? target,
        end: target,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _Painter(
            temp: _tempTweens!,
            pop: _popTweens!,
            animation: _animation,
          ),
        );
      },
    );
  }
}

class _Painter extends CustomPainter {
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

  final List<Tween<Offset>> temp;
  final List<Tween<Offset>> pop;

  final Animation<double> animation;

  _Painter({
    required this.temp,
    required this.pop,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 表示範囲は全体で 50%、それぞれ 25% とする

    final tempOffsets = temp.map((e) => e.evaluate(animation)).toList();
    final popOffsets = pop.map((e) => e.evaluate(animation)).toList();

    final tempLinePath = Path();
    tempLinePath.moveTo(tempOffsets[0].dx, tempOffsets[0].dy);
    for (var v in tempOffsets) {
      tempLinePath.lineTo(v.dx, v.dy);
    }

    final tempFillPath = Path();
    tempFillPath.moveTo(tempOffsets[0].dx, tempOffsets[0].dy);
    for (var v in tempOffsets) {
      tempFillPath.lineTo(v.dx, v.dy);
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

    canvas.drawPath(tempFillPath, _Painter._tempFillPaint);
    canvas.drawPath(tempLinePath, _Painter._tempLinePaint);
    canvas.drawPath(popFillPath, _Painter._popFillPaint);
    canvas.drawPath(popLinePath, _Painter._popLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
