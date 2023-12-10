import 'package:flutter/material.dart';

enum TriangleDirection { up, down }

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final TriangleDirection direction;
  final double heightFactor;

  TrianglePainter({
    required this.strokeColor,
    required this.paintingStyle,
    required this.direction,
    this.heightFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    double offsetY = y * (1 - heightFactor) / 2;

    return Path()
      ..moveTo(0, direction == TriangleDirection.up ? y - offsetY : offsetY)
      ..lineTo(x / 2, direction == TriangleDirection.up ? offsetY : y - offsetY)
      ..lineTo(x, direction == TriangleDirection.up ? y - offsetY : offsetY)
      ..lineTo(0, direction == TriangleDirection.up ? y - offsetY : offsetY);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
