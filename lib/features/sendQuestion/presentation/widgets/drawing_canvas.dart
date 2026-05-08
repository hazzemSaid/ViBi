import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../cubit/drawing_cubit.dart';

/**
 * Custom painter that renders a list of strokes using [perfect_freehand]
 * for a smooth, natural drawing feel.
 */
class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color backgroundColor;

  DrawingPainter({
    required this.strokes,
    required this.backgroundColor,
    this.currentStroke,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // Solid background for clean PNG export
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    final activeStroke = currentStroke;
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final cachedPath = stroke.cachedPath;
    if (cachedPath != null &&
        stroke.cachedPathPointCount == stroke.points.length) {
      canvas.drawPath(cachedPath, _paintForStroke(stroke));
      return;
    }

    final inputPoints = stroke.points
        .map((p) => PointVector(p.dx, p.dy))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: stroke.width * 2,
        thinning: 0.6,
        smoothing: 0.65,
        streamline: 0.6,
        simulatePressure: true,
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = Path();
    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 1; i < outlinePoints.length - 1; i++) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }
    path.close();
    stroke.cachePath(path);

    canvas.drawPath(path, _paintForStroke(stroke));
  }

  Paint _paintForStroke(Stroke stroke) {
    return Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  @override
  bool shouldRepaint(DrawingPainter old) =>
      old.strokes != strokes ||
      old.currentStroke != currentStroke ||
      old.backgroundColor != backgroundColor;
}
