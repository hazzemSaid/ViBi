import 'package:flutter/material.dart';

import '../cubit/drawing_cubit.dart';
import 'drawing_canvas.dart';

/// Custom painter that renders the minimap preview and viewport indicator.
class MiniMapPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color backgroundColor;
  final Size canvasSize;
  final Size miniSize;
  final Rect? visibleRect;
  final Color primaryColor;
  final Color viewportFillColor;

  MiniMapPainter({
    required this.strokes,
    required this.backgroundColor,
    required this.canvasSize,
    required this.miniSize,
    required this.visibleRect,
    required this.primaryColor,
    required this.viewportFillColor,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (canvasSize == Size.zero) return;
    // Scale drawing to fit minimap.
    final double scaleX = size.width / canvasSize.width;
    final double scaleY = size.height / canvasSize.height;
    canvas.save();
    canvas.scale(scaleX, scaleY);
    // Paint the actual strokes using existing painter.
    DrawingPainter(
      strokes: strokes,
      backgroundColor: backgroundColor,
      currentStroke: currentStroke,
    ).paint(canvas, canvasSize);
    canvas.restore();

    // Draw viewport indicator.
    final Rect? rect = visibleRect;
    if (rect == null || rect.isEmpty) return;
    final Rect viewport = Rect.fromLTWH(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.width * scaleX,
      rect.height * scaleY,
    );
    final Paint viewportPaint = Paint()
      ..color = viewportFillColor
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(viewport, viewportPaint);
    canvas.drawRect(viewport, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MiniMapPainter old) =>
      old.strokes != strokes ||
      old.currentStroke != currentStroke ||
      old.primaryColor != primaryColor ||
      old.viewportFillColor != viewportFillColor ||
      old.visibleRect != visibleRect;
}
