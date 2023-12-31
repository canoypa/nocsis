import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocsis_classroom/models/weather.dart';

class WeatherGraph extends ConsumerStatefulWidget {
  const WeatherGraph({Key? key}) : super(key: key);

  @override
  WeatherGraphState createState() => WeatherGraphState();
}

class WeatherGraphState extends ConsumerState
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  WeatherGraphState();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    weatherData = _generateDummyWeatherData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  late WeatherHourly weatherData;
  _generateDummyWeatherData() {
    final temp = List.generate(9, (i) => Random().nextInt(10));
    final pop = List.generate(9, (i) => Random().nextDouble());

    final tempMax = temp.reduce(max);
    final tempMin = temp.reduce(min);

    _tempTweens = temp.asMap().entries.map((e) {
      return Tween(
        begin: _tempTweens[e.key].evaluate(_animation),
        end: Offset(e.key / (temp.length - 1),
            (e.value - tempMin) / (tempMax - tempMin)),
      );
    }).toList();
    _popTweens = pop.asMap().entries.map((e) {
      return Tween(
        begin: _popTweens[e.key].evaluate(_animation),
        end: Offset(e.key / (pop.length - 1), e.value.toDouble()),
      );
    }).toList();

    return WeatherHourly(temp: temp, pop: pop);
  }

  late final CurvedAnimation _animation =
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo);
  List<Tween<Offset>> _tempTweens =
      List.generate(9, (_) => Tween(begin: Offset.zero));
  List<Tween<Offset>> _popTweens =
      List.generate(9, (_) => Tween(begin: Offset.zero));

  @override
  Widget build(BuildContext context) {
    // final weatherData = ref.watch(weatherProvider).maybeWhen(
    //       data: (data) => data.hourly,
    //       orElse: () => const WeatherHourly(temp: [0, 0], pop: [0, 0]),
    //     );

    // final tempData = weatherData.temp;
    // final tempMax = tempData.reduce(max);
    // final tempMin = tempData.reduce(min);

    // final popData = weatherData.pop;

    // final temp = tempData.asMap().entries.map((e) {
    //   return Offset(
    //     e.key / (tempData.length - 1),
    //     (e.value - tempMin) / (tempMax - tempMin),
    //   );
    // }).toList();
    // final pop = popData.asMap().entries.map((e) {
    //   return Offset(
    //     e.key / (popData.length - 1),
    //     e.value.toDouble(),
    //   );
    // }).toList();

    // _animationController.reset();

    return SizedBox.expand(
      child: GestureDetector(
        onTap: () {
          setState(() {
            weatherData = _generateDummyWeatherData();
            _animationController
              ..reset()
              ..forward();
          });
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            return CustomPaint(
              painter: _WeatherGraphPainter(
                temp: _tempTweens,
                pop: _popTweens,
                controller: _animationController,
                animation: _animation,
              ),
            );
          },
        ),
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

  final List<Tween<Offset>> temp;
  final List<Tween<Offset>> pop;

  final AnimationController controller;
  final Animation<double> animation;

  _WeatherGraphPainter({
    required this.temp,
    required this.pop,
    required this.controller,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 表示範囲は全体で 50%、それぞれ 25% とする

    // final progress = curve.transform(animationProgress);

    final tempOffsets = temp.map((v) {
      final value = v.evaluate(animation);
      return Offset(
        value.dx * size.width,
        size.height - (value.dy * size.height * 0.25 + size.height * 0.25),
      );
    }).toList();
    final popOffsets = pop.map((v) {
      final value = v.evaluate(animation);
      return Offset(
        value.dx * size.width,
        size.height - value.dy * (size.height * 0.25),
      );
    }).toList();

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
