import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis/models/classes.dart';

class DuringClassProgress extends StatefulWidget {
  final ClassData data;

  const DuringClassProgress({super.key, required this.data});

  @override
  State<DuringClassProgress> createState() => _DuringClassProgressState();
}

class _DuringClassProgressState extends State<DuringClassProgress>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final classTerm = widget.data.endAt.difference(widget.data.startAt);
    final progress =
        DateTime.now().difference(widget.data.startAt).inSeconds /
        classTerm.inSeconds;

    return SizedBox.expand(
      child: CustomPaint(
        painter: _DuringClassProgressPainter(
          progress: progress,
          primary: theme.colorScheme.primary,
          secondary: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _DuringClassProgressPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;

  late final linePaint =
      Paint()
        ..color = secondary
        ..strokeWidth = 24.sp
        ..style = PaintingStyle.stroke;
  late final progressPaint =
      Paint()
        ..color = primary
        ..strokeWidth = 24.sp
        ..style = PaintingStyle.stroke;

  _DuringClassProgressPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(size.width / 2, 36.sp)
          ..lineTo(size.width - 60.sp, 36.sp)
          ..arcToPoint(
            Offset(size.width - 36.sp, 60.sp),
            radius: Radius.circular(24.sp),
          )
          ..lineTo(size.width - 36.sp, size.height - 60.sp)
          ..arcToPoint(
            Offset(size.width - 60.sp, size.height - 36.sp),
            radius: Radius.circular(24.sp),
          )
          ..lineTo(60.sp, size.height - 36.sp)
          ..arcToPoint(
            Offset(36.sp, size.height - 60.sp),
            radius: Radius.circular(24.sp),
          )
          ..lineTo(36.sp, 60.sp)
          ..arcToPoint(Offset(60.sp, 36.sp), radius: Radius.circular(24.sp))
          ..close();

    final pathMetric = path.computeMetrics().first;
    final progressPath = pathMetric.extractPath(
      0,
      pathMetric.length * progress,
    );

    canvas
      ..drawPath(path, linePaint)
      ..drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(_DuringClassProgressPainter oldDelegate) {
    return true;
  }
}
