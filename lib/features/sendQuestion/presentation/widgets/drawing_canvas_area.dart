import 'package:flutter/material.dart';

import '../cubit/drawing_cubit.dart';
import 'drawing_canvas.dart';
import 'drawing_minimap.dart';

/**
 * The interactive canvas area for drawing.
 *
 * Manages pointer input (down/move/up/cancel), clamps strokes to the canvas
 * bounds, and wraps everything in an [InteractiveViewer] for pinch-to-zoom
 * and pan when in zoom mode.
 *
 * Also renders a [DrawingMiniMap] overlay when zoom mode is active.
 */
class DrawingCanvasArea extends StatefulWidget {
  final DrawingState state;
  final DrawingCubit cubit;
  final bool isZoomMode;
  final TransformationController transformController;
  final GlobalKey repaintKey;
  final GlobalKey viewportKey;
  final double aspectRatio;

  const DrawingCanvasArea({
    super.key,
    required this.state,
    required this.cubit,
    required this.isZoomMode,
    required this.transformController,
    required this.repaintKey,
    required this.viewportKey,
    required this.aspectRatio,
  });

  @override
  State<DrawingCanvasArea> createState() => _DrawingCanvasAreaState();
}

class _DrawingCanvasAreaState extends State<DrawingCanvasArea> {
  int _activePointers = 0;
  int? _drawingPointer;
  Offset? _pendingPoint;
  bool _isDrawing = false;

  Offset? _eventToCanvas(PointerEvent event) {
    final renderObject =
        widget.repaintKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;
    return renderObject.globalToLocal(event.position);
  }

  Size? _canvasSize() {
    final renderObject =
        widget.repaintKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || renderObject.size.isEmpty) return null;
    return renderObject.size;
  }

  bool _isInsideCanvas(Offset point, Size size) {
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= size.width &&
        point.dy <= size.height;
  }

  Offset _clampToCanvas(Offset point, Size size) {
    return Offset(
      point.dx.clamp(0.0, size.width),
      point.dy.clamp(0.0, size.height),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers++;
    if (_activePointers == 1) {
      final point = _eventToCanvas(event);
      final size = _canvasSize();
      if (point == null || size == null || !_isInsideCanvas(point, size)) {
        return;
      }
      _drawingPointer = event.pointer;
      _pendingPoint = point;
      _isDrawing = false;
    } else if (_drawingPointer != null) {
      widget.cubit.endStroke();
      _drawingPointer = null;
      _pendingPoint = null;
      _isDrawing = false;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_drawingPointer != event.pointer) return;
    if (_activePointers != 1) return;
    final point = _eventToCanvas(event);
    final size = _canvasSize();
    if (point == null || size == null) return;

    if (!_isInsideCanvas(point, size)) {
      if (_isDrawing) {
        widget.cubit.continueStroke(_clampToCanvas(point, size));
        widget.cubit.endStroke();
      }
      _pendingPoint = null;
      _isDrawing = false;
      return;
    }

    if (!_isDrawing) {
      final pending = _pendingPoint ?? point;
      _pendingPoint = pending;
      if ((pending - point).distance < 3) return;
      widget.cubit.startStroke(pending);
      _isDrawing = true;
    }
    widget.cubit.continueStroke(point);
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 10);
    if (_drawingPointer == event.pointer) {
      widget.cubit.endStroke();
      _drawingPointer = null;
      _pendingPoint = null;
      _isDrawing = false;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers = 0;
    if (_drawingPointer == event.pointer) {
      widget.cubit.endStroke();
      _drawingPointer = null;
      _pendingPoint = null;
      _isDrawing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvas = RepaintBoundary(
      key: widget.repaintKey,
      child: CustomPaint(
        painter: DrawingPainter(
          strokes: widget.state.strokes,
          backgroundColor: Colors.white,
          currentStroke: widget.state.currentStroke,
          repaint: widget.cubit.repaintNotifier,
        ),
        child: const SizedBox.expand(),
      ),
    );

    return LayoutBuilder(
      builder: (context, _) {
        return Stack(
          children: [
            SizedBox(
              key: widget.viewportKey,
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                transformationController: widget.transformController,
                panEnabled: widget.isZoomMode,
                scaleEnabled: widget.isZoomMode,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: widget.isZoomMode
                          ? canvas
                          : Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: _onPointerDown,
                              onPointerMove: _onPointerMove,
                              onPointerUp: _onPointerUp,
                              onPointerCancel: _onPointerCancel,
                              child: canvas,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.92,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: widget.isZoomMode
                    ? DrawingMiniMap(
                        key: const ValueKey('minimap'),
                        strokes: widget.state.strokes,
                        currentStroke: widget.state.currentStroke,
                        backgroundColor: Colors.white,
                        transformController: widget.transformController,
                        repaintKey: widget.repaintKey,
                        viewportKey: widget.viewportKey,
                        aspectRatio: widget.aspectRatio,
                      )
                    : const SizedBox(
                        key: ValueKey('minimap-hidden'),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
