import 'package:flutter/material.dart';

/// Helper class for minimap geometry and bounds calculations.
class MiniMapGeometry {
  /// Calculates the visible canvas rect from viewport and canvas render boxes.
  static Rect visibleCanvasRectFromBoxes(
    RenderBox canvasBox,
    RenderBox viewportBox,
    Size canvasSize,
  ) {
    final Offset viewportTopLeft = viewportBox.localToGlobal(Offset.zero);
    final Offset viewportBottomRight = viewportBox.localToGlobal(
      viewportBox.size.bottomRight(Offset.zero),
    );
    final Offset canvasTopLeft = canvasBox.globalToLocal(viewportTopLeft);
    final Offset canvasBottomRight = canvasBox.globalToLocal(
      viewportBottomRight,
    );
    final Rect rect = Rect.fromPoints(canvasTopLeft, canvasBottomRight);
    final Rect bounds = Rect.fromLTWH(
      0,
      0,
      canvasSize.width,
      canvasSize.height,
    );
    return rect.intersect(bounds);
  }

  /// Converts minimap coordinates to canvas coordinates.
  static Offset miniToCanvasPoint(
    Offset miniPoint,
    Size canvasSize,
    Size miniSize,
  ) {
    final double scaleX = canvasSize.width / miniSize.width;
    final double scaleY = canvasSize.height / miniSize.height;
    return Offset(miniPoint.dx * scaleX, miniPoint.dy * scaleY);
  }

  /// Converts canvas coordinates to minimap coordinates.
  static Offset canvasToMiniPoint(
    Offset canvasPoint,
    Size canvasSize,
    Size miniSize,
  ) {
    final double scaleX = miniSize.width / canvasSize.width;
    final double scaleY = miniSize.height / canvasSize.height;
    return Offset(canvasPoint.dx * scaleX, canvasPoint.dy * scaleY);
  }

  /// Scales a rect from canvas to minimap coordinates.
  static Rect canvasToMiniRect(
    Rect canvasRect,
    Size canvasSize,
    Size miniSize,
  ) {
    final double scaleX = miniSize.width / canvasSize.width;
    final double scaleY = miniSize.height / canvasSize.height;
    return Rect.fromLTWH(
      canvasRect.left * scaleX,
      canvasRect.top * scaleY,
      canvasRect.width * scaleX,
      canvasRect.height * scaleY,
    );
  }

  /// Clamps a point within canvas bounds.
  static Offset clampPointInCanvas(
    Offset point,
    Size viewSize,
    Size canvasSize,
  ) {
    final double maxLeft = canvasSize.width - viewSize.width;
    final double maxTop = canvasSize.height - viewSize.height;
    return Offset(
      point.dx.clamp(0.0, maxLeft < 0 ? 0.0 : maxLeft),
      point.dy.clamp(0.0, maxTop < 0 ? 0.0 : maxTop),
    );
  }
}
