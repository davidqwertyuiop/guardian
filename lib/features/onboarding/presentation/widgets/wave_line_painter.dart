import 'package:flutter/material.dart';

class WaveLinePainter extends CustomPainter {
  const WaveLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintYellow = Paint()
      ..color = const Color(0xFFFFD23F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final paintWhite = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw yellow brush line (lower wave)
    final pathYellow = Path();
    pathYellow.moveTo(20, size.height * 0.6);
    pathYellow.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.7,
    );
    canvas.drawPath(pathYellow, paintYellow);

    // Draw white/lavender brush line (upper parallel wave)
    final pathWhite = Path();
    pathWhite.moveTo(24, size.height * 0.45);
    pathWhite.quadraticBezierTo(
      size.width * 0.42,
      size.height * 0.1,
      size.width * 0.88,
      size.height * 0.55,
    );
    canvas.drawPath(pathWhite, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
