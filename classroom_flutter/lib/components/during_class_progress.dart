import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DuringClassProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _DuringClassProgressPainter(),
      ),
    );
  }
}

class _DuringClassProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const exampleProgress = 0.5;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24.sp
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 24.sp
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 36.sp)
      ..lineTo(size.width - 60.sp, 36.sp)
      ..arcToPoint(Offset(size.width - 36.sp, 60.sp),
          radius: Radius.circular(24.sp))
      ..lineTo(size.width - 36.sp, size.height - 60.sp)
      ..arcToPoint(Offset(size.width - 60.sp, size.height - 36.sp),
          radius: Radius.circular(24.sp))
      ..lineTo(60.sp, size.height - 36.sp)
      ..arcToPoint(Offset(36.sp, size.height - 60.sp),
          radius: Radius.circular(24.sp))
      ..lineTo(36.sp, 60.sp)
      ..arcToPoint(Offset(60.sp, 36.sp), radius: Radius.circular(24.sp))
      ..close();

    final pathMetric = path.computeMetrics().first;
    final progressPath =
        pathMetric.extractPath(0, pathMetric.length * exampleProgress);

    canvas
      ..drawPath(path, linePaint)
      ..drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(_DuringClassProgressPainter oldDelegate) {
    return true;
  }
}
