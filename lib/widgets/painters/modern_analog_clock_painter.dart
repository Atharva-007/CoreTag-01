import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernAnalogClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final int second;
  final Color color;
  final bool showMarkers;

  ModernAnalogClockPainter({
    required this.hour,
    required this.minute,
    required this.second,
    required this.color,
    required this.showMarkers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (showMarkers) {
      final markerPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * math.pi / 180;
        final startRadius = radius * 0.80;
        final endRadius = i % 3 == 0 ? radius * 0.70 : radius * 0.75;
        
        canvas.drawLine(
          Offset(
            center.dx + startRadius * math.sin(angle),
            center.dy - startRadius * math.cos(angle),
          ),
          Offset(
            center.dx + endRadius * math.sin(angle),
            center.dy - endRadius * math.cos(angle),
          ),
          markerPaint,
        );
      }
    }

    final hourAngle = (hour * 30 + minute * 0.5) * math.pi / 180;
    final hourPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.4 * math.sin(hourAngle),
        center.dy - radius * 0.4 * math.cos(hourAngle),
      ),
      hourPaint,
    );

    final minuteAngle = minute * 6 * math.pi / 180;
    final minutePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.6 * math.sin(minuteAngle),
        center.dy - radius * 0.6 * math.cos(minuteAngle),
      ),
      minutePaint,
    );

    final centerCirclePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
