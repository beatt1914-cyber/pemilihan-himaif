import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HimaifLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBg;

  const HimaifLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.darkBg = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _CircuitLogoPainter(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: size * 0.2),
                child: Text(
                  'HIMAIF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          Text(
            'HIMAIF',
            style: TextStyle(
              color: darkBg ? Colors.white : AppColors.primaryDark,
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          Text(
            'INFORMATIKA',
            style: TextStyle(
              color: (darkBg ? Colors.white : AppColors.primaryDark)
                  .withValues(alpha: 0.7),
              fontSize: size * 0.1,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _CircuitLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2 - size.height * 0.08;
    final r = size.width * 0.28;

    // Circuit lines
    final pts = [
      [cx, cy - r],
      [cx - r * 0.7, cy - r * 0.5],
      [cx + r * 0.7, cy - r * 0.5],
      [cx - r * 0.4, cy],
      [cx + r * 0.4, cy],
    ];

    canvas.drawLine(Offset(pts[0][0], pts[0][1]), Offset(cx, cy - r * 0.3), paint);
    canvas.drawLine(Offset(pts[1][0], pts[1][1]), Offset(cx - r * 0.4, cy), paint);
    canvas.drawLine(Offset(pts[2][0], pts[2][1]), Offset(cx + r * 0.4, cy), paint);
    canvas.drawLine(Offset(cx - r * 0.4, cy), Offset(cx + r * 0.4, cy), paint);
    canvas.drawLine(Offset(cx - r * 0.7, cy - r * 0.5), Offset(cx - r * 0.15, cy - r * 0.5), paint);
    canvas.drawLine(Offset(cx + r * 0.15, cy - r * 0.5), Offset(cx + r * 0.7, cy - r * 0.5), paint);

    // Dots
    paint.style = PaintingStyle.fill;
    for (final p in pts) {
      canvas.drawCircle(Offset(p[0], p[1]), 3.5, paint);
    }
    canvas.drawCircle(Offset(cx, cy - r * 0.3), 2.5, paint);

    // Outer ring text arc (approximated with small dots)
    paint.color = Colors.white.withValues(alpha: 0.3);
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * pi / 180;
      final rx = cx + (size.width * 0.44) * cos(angle);
      final ry = cy + (size.height * 0.44) * sin(angle);
      canvas.drawCircle(Offset(rx, ry), 0.8, paint);
    }

    // Bottom smile arc
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white.withValues(alpha: 0.6);
    paint.strokeWidth = 1.5;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy + size.height * 0.18),
      width: size.width * 0.55,
      height: size.height * 0.18,
    );
    canvas.drawArc(rect, 0, pi, false, paint);
    canvas.drawLine(
      Offset(cx, cy + size.height * 0.27),
      Offset(cx, cy + size.height * 0.35),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
