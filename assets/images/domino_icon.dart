import 'package:flutter/material.dart';

class DominoIcon extends StatelessWidget {
  final double size;
  final Color color;

  const DominoIcon({
    super.key,
    this.size = 24.0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DominoPainter(color: color),
    );
  }
}

class _DominoPainter extends CustomPainter {
  final Color color;

  _DominoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw domino rectangle
    final RRect dominoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.8, size.height * 0.8),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(dominoRect, paint);

    // Draw dividing line
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.5),
      linePaint,
    );

    // Draw dots
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Top dots (3 dots)
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.25),
      size.width * 0.06,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.06,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.25),
      size.width * 0.06,
      dotPaint,
    );

    // Bottom dots (2 dots)
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.75),
      size.width * 0.06,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.75),
      size.width * 0.06,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
