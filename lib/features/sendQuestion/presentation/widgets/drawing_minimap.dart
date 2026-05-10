import 'package:flutter/material.dart';

import '../cubit/drawing_cubit.dart';
import 'minimap_geometry.dart';
import 'minimap_painter.dart';

/// A minimap that shows a scaled preview of the drawing canvas.
/// Visible only when [_mode] is [_CanvasMode.zoom].
class DrawingMiniMap extends StatefulWidget {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color backgroundColor;
  final TransformationController transformController;
  final GlobalKey repaintKey;
  final GlobalKey viewportKey;
  final double aspectRatio;

  const DrawingMiniMap({
    super.key,
    required this.strokes,
    required this.backgroundColor,
    required this.transformController,
    required this.repaintKey,
    required this.viewportKey,
    required this.aspectRatio,
    this.currentStroke,
  });

  @override
  State<DrawingMiniMap> createState() => _DrawingMiniMapState();
}

class _DrawingMiniMapState extends State<DrawingMiniMap> {
  bool _draggingViewport = false;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // Determine minimap size based on aspect ratio.
    final double width = widget.aspectRatio > 1 ? 140 : 72;
    final double height = widget.aspectRatio > 1 ? 72 : 168;
    final Size miniSize = Size(width, height);

    // Get the logical canvas size from the main repaint boundary.
    final renderObject = widget.repaintKey.currentContext?.findRenderObject();
    final Size canvasSize = (renderObject is RenderBox)
        ? renderObject.size
        : Size.zero;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) =>
          _handleTap(details.localPosition, canvasSize, miniSize),
      onPanStart: (details) =>
          _handlePanStart(details.localPosition, canvasSize, miniSize),
      onPanUpdate: (details) =>
          _handlePanUpdate(details.localPosition, canvasSize, miniSize),
      onPanEnd: (_) => _draggingViewport = false,
      onPanCancel: () => _draggingViewport = false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: AnimatedBuilder(
            animation: widget.transformController,
            builder: (context, _) {
              final Rect? visibleRect = _visibleCanvasRect(canvasSize);
              return CustomPaint(
                painter: MiniMapPainter(
                  strokes: widget.strokes,
                  currentStroke: widget.currentStroke,
                  backgroundColor: widget.backgroundColor,
                  canvasSize: canvasSize,
                  miniSize: miniSize,
                  visibleRect: visibleRect,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  viewportFillColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handlePanStart(Offset local, Size canvasSize, Size miniSize) {
    if (canvasSize == Size.zero) return;
    final Rect? viewport = _viewportRect(canvasSize, miniSize);
    if (viewport == null) return;
    if (viewport.contains(local)) {
      _draggingViewport = true;
      _dragOffset = local - viewport.topLeft;
    } else {
      _draggingViewport = false;
    }
  }

  void _handlePanUpdate(Offset local, Size canvasSize, Size miniSize) {
    if (!_draggingViewport) {
      _handleTap(local, canvasSize, miniSize);
      return;
    }
    _moveViewportTo(local - _dragOffset, canvasSize, miniSize);
  }

  void _handleTap(Offset local, Size canvasSize, Size miniSize) {
    if (canvasSize == Size.zero) return;
    final Rect? currentView = _currentViewRect(canvasSize);
    if (currentView == null) return;

    final Offset canvasPoint = MiniMapGeometry.miniToCanvasPoint(
      local,
      canvasSize,
      miniSize,
    );

    final double viewWidth = currentView.width;
    final double viewHeight = currentView.height;
    final double halfW = viewWidth / 2;
    final double halfH = viewHeight / 2;

    final double targetLeft = canvasPoint.dx - halfW;
    final double targetTop = canvasPoint.dy - halfH;
    final Offset clampedPoint = MiniMapGeometry.clampPointInCanvas(
      Offset(targetLeft, targetTop),
      Size(viewWidth, viewHeight),
      canvasSize,
    );

    _applyViewTopLeft(clampedPoint, currentView);
  }

  void _moveViewportTo(Offset viewTopLeftMini, Size canvasSize, Size miniSize) {
    if (canvasSize == Size.zero) return;
    final Rect? currentView = _currentViewRect(canvasSize);
    if (currentView == null) return;

    final Offset canvasPoint = MiniMapGeometry.miniToCanvasPoint(
      viewTopLeftMini,
      canvasSize,
      miniSize,
    );
    final Offset clampedPoint = MiniMapGeometry.clampPointInCanvas(
      canvasPoint,
      Size(currentView.width, currentView.height),
      canvasSize,
    );

    _applyViewTopLeft(clampedPoint, currentView);
  }

  Rect? _viewportRect(Size canvasSize, Size miniSize) {
    final Rect? currentView = _currentViewRect(canvasSize);
    if (currentView == null) return null;
    return MiniMapGeometry.canvasToMiniRect(currentView, canvasSize, miniSize);
  }

  Rect? _currentViewRect(Size canvasSize) {
    final RenderBox? canvasBox =
        widget.repaintKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? viewportBox =
        widget.viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null || viewportBox == null) return null;
    return _visibleCanvasRectFromBoxes(canvasBox, viewportBox, canvasSize);
  }

  Rect? _visibleCanvasRect(Size canvasSize) {
    final RenderBox? canvasBox =
        widget.repaintKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? viewportBox =
        widget.viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null || viewportBox == null) return null;
    return _visibleCanvasRectFromBoxes(canvasBox, viewportBox, canvasSize);
  }

  Rect _visibleCanvasRectFromBoxes(
    RenderBox canvasBox,
    RenderBox viewportBox,
    Size canvasSize,
  ) {
    return MiniMapGeometry.visibleCanvasRectFromBoxes(
      canvasBox,
      viewportBox,
      canvasSize,
    );
  }

  void _applyViewTopLeft(Offset desiredTopLeft, Rect currentView) {
    final Offset delta = desiredTopLeft - currentView.topLeft;
    final Matrix4 currentMatrix = widget.transformController.value.clone();
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double nextX = currentMatrix[12] - delta.dx * currentScale;
    final double nextY = currentMatrix[13] - delta.dy * currentScale;
    currentMatrix.setTranslationRaw(nextX, nextY, currentMatrix[14]);
    widget.transformController.value = currentMatrix;
  }
}
