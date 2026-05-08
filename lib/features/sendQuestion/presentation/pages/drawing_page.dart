import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/constants/app_sizes.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/drawing_cubit.dart';
import '../cubit/send_drawing_cubit.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_canvas_area.dart';
import '../widgets/drawing_mode_banner.dart';
import '../widgets/drawing_send_dialog.dart';
import '../widgets/drawing_toolbar.dart';

/**
 * Full-screen drawing composer.
 *
 * Provides a canvas for freehand drawing with undo/redo, eraser, color/width
 * selection, and pinch-to-zoom. The final drawing is rasterized at a fixed
 * export resolution and uploaded via [SendDrawingCubit].
 *
 * Layout:
 *   AppBar (mode toggle, send button)
 *   [DrawingModeBanner]
 *   [DrawingCanvasArea] (interactive canvas + minimap overlay)
 *   [DrawingToolbar] (undo, redo, clear, eraser, color, width)
 */
class DrawingPage extends StatefulWidget {
  final String recipientId;
  final String? senderId;

  const DrawingPage({
    super.key,
    required this.recipientId,
    this.senderId,
  });

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

/**
 * Whether the canvas is in draw mode (captures pointer strokes) or
 * zoom mode (pinch/pan via InteractiveViewer).
 */
enum _CanvasMode { draw, zoom }

/// Aspect ratio of the canvas (4:3 landscape).
const double _canvasAspectRatio = 4 / 3;

/// Fixed resolution at which the drawing is rasterized for export.
const Size _drawingExportSize = Size(1600, 1200);

class _DrawingPageState extends State<DrawingPage> {
  final _repaintKey = GlobalKey();
  final _transformController = TransformationController();
  final _viewportKey = GlobalKey();

  _CanvasMode _mode = _CanvasMode.draw;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _transformController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  /**
   * Rasterizes the current drawing at [_drawingExportSize] by replaying all
   * strokes onto an offscreen [Canvas] at the target resolution.
   */
  Future<Uint8List> _rasterize(DrawingState drawingState) async {
    final repaintContext = _repaintKey.currentContext;
    if (repaintContext == null) {
      throw StateError('Drawing canvas is still loading. Please try again.');
    }
    final renderObject = repaintContext.findRenderObject();
    if (renderObject is! RenderBox || renderObject.size.isEmpty) {
      throw StateError('Drawing canvas is not ready to export.');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final sourceSize = renderObject.size;
    canvas.scale(
      _drawingExportSize.width / sourceSize.width,
      _drawingExportSize.height / sourceSize.height,
    );
    DrawingPainter(
      strokes: drawingState.strokes,
      backgroundColor: Colors.white,
      currentStroke: drawingState.currentStroke,
    ).paint(canvas, sourceSize);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _drawingExportSize.width.toInt(),
      _drawingExportSize.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (byteData == null) {
      throw StateError('Failed to encode drawing image.');
    }
    return byteData.buffer.asUint8List();
  }

  /**
   * Validates the drawing is non-empty, shows the [DrawingSendDialog], and
   * uploads the rasterized PNG via [SendDrawingCubit].
   */
  void _onSend(BuildContext context) async {
    final drawingCubit = context.read<DrawingCubit>();
    if (drawingCubit.state.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something first!')),
      );
      return;
    }

    final result = await DrawingSendDialog.show(context);
    if (result == null || !context.mounted) return;

    Uint8List pngBytes;
    try {
      pngBytes = await _rasterize(drawingCubit.state);
    } on StateError catch (e) {
      if (!context.mounted) return;
      final errorMessage =
          (e.message as String?) ?? 'Failed to export drawing.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    if (!context.mounted) return;

    context.read<SendDrawingCubit>().send(
      recipientId: widget.recipientId,
      pngBytes: pngBytes,
      isAnonymous: result,
      senderId: result ? null : widget.senderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DrawingCubit()),
        BlocProvider(create: (_) => getIt<SendDrawingCubit>()),
      ],
      child: BlocConsumer<SendDrawingCubit, SendDrawingState>(
        listener: (context, state) {
          if (state is SendDrawingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drawing sent!')),
            );
            Navigator.pop(context, true);
          } else if (state is SendDrawingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${state.message}')),
            );
            context.read<SendDrawingCubit>().reset();
          }
        },
        builder: (context, sendState) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Send Drawing'),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              actions: [
                // Toggle between draw and zoom mode
                IconButton(
                  tooltip: _mode == _CanvasMode.draw
                      ? 'Switch to Zoom'
                      : 'Switch to Draw',
                  icon: Icon(
                    _mode == _CanvasMode.draw
                        ? Icons.zoom_in_rounded
                        : Icons.edit_rounded,
                  ),
                  onPressed: () => setState(() {
                    _mode = _mode == _CanvasMode.draw
                        ? _CanvasMode.zoom
                        : _CanvasMode.draw;
                  }),
                ),
                if (sendState is SendDrawingLoading)
                  Padding(
                    padding: EdgeInsets.all(AppSizes.s14),
                    child: SizedBox(
                      width: AppSizes.s20,
                      height: AppSizes.s20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => _onSend(context),
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            body: BlocBuilder<DrawingCubit, DrawingState>(
              builder: (context, drawState) {
                final cubit = context.read<DrawingCubit>();

                return Column(
                  children: [
                    DrawingModeBanner(
                      isZoomMode: _mode == _CanvasMode.zoom,
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.035),
                        ),
                        child: DrawingCanvasArea(
                          state: drawState,
                          cubit: cubit,
                          isZoomMode: _mode == _CanvasMode.zoom,
                          transformController: _transformController,
                          repaintKey: _repaintKey,
                          viewportKey: _viewportKey,
                          aspectRatio: _canvasAspectRatio,
                        ),
                      ),
                    ),
                    DrawingToolbar(
                      state: drawState,
                      cubit: cubit,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
