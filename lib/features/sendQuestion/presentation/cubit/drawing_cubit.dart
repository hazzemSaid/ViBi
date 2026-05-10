import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Stroke model ────────────────────────────────────────────────────────────

/**
 * Represents a single continuous line segment in a drawing.
 */
class Stroke extends Equatable {
  final List<Offset> points;
  final Color color;
  final double width;
  Path? _cachedPath;
  int _cachedPathPointCount = 0;

  Stroke({required this.points, required this.color, required this.width});

  /**
   * Returns a copy of this stroke with an additional point.
   */
  Stroke copyWithPoint(Offset point) =>
      Stroke(points: [...points, point], color: color, width: width);

  Path? get cachedPath => _cachedPath;
  int get cachedPathPointCount => _cachedPathPointCount;

  void cachePath(Path path) {
    _cachedPath = path;
    _cachedPathPointCount = points.length;
  }

  @override
  List<Object?> get props => [points, color, width];
}

// ─── State ───────────────────────────────────────────────────────────────────

/**
 * State representation for the drawing canvas.
 */
class DrawingState extends Equatable {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final Color lastBrushColor;
  final List<Stroke> undoStack;

  const DrawingState({
    this.strokes = const [],
    this.currentStroke,
    this.selectedColor = const Color(0xFF000000),
    this.selectedWidth = 4.0,
    this.isEraser = false,
    this.lastBrushColor = const Color(0xFF000000),
    this.undoStack = const [],
  });

  bool get isEmpty => strokes.isEmpty && currentStroke == null;
  bool get canRedo => undoStack.isNotEmpty;

  DrawingState copyWith({
    List<Stroke>? strokes,
    Stroke? currentStroke,
    bool clearCurrentStroke = false,
    Color? selectedColor,
    double? selectedWidth,
    bool? isEraser,
    Color? lastBrushColor,
    List<Stroke>? undoStack,
  }) {
    return DrawingState(
      strokes: strokes ?? this.strokes,
      currentStroke: clearCurrentStroke
          ? null
          : (currentStroke ?? this.currentStroke),
      selectedColor: selectedColor ?? this.selectedColor,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      isEraser: isEraser ?? this.isEraser,
      lastBrushColor: lastBrushColor ?? this.lastBrushColor,
      undoStack: undoStack ?? this.undoStack,
    );
  }

  @override
  List<Object?> get props => [
    strokes,
    currentStroke,
    selectedColor,
    selectedWidth,
    isEraser,
    lastBrushColor,
    undoStack,
  ];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

/**
 * Manages the drawing canvas state, including stroke tracking and styling.
 */
class DrawingCubit extends Cubit<DrawingState> {
  DrawingCubit() : super(const DrawingState());

  final ValueNotifier<int> repaintNotifier = ValueNotifier<int>(0);

  static const double _minPointDistance = 1.2;

  void _requestRepaint() {
    repaintNotifier.value++;
  }

  @override
  Future<void> close() {
    repaintNotifier.dispose();
    return super.close();
  }

  /**
   * Initiates a new stroke at the given [point].
   */
  void startStroke(Offset point) {
    emit(
      state.copyWith(
        currentStroke: Stroke(
          points: [point],
          color: state.selectedColor,
          width: state.selectedWidth,
        ),
        undoStack: [],
      ),
    );
    _requestRepaint();
  }

  /**
   * Appends a new point to the current active stroke.
   */
  void continueStroke(Offset point) {
    final current = state.currentStroke;
    if (current == null) return;
    if (current.points.isNotEmpty &&
        (current.points.last - point).distance < _minPointDistance) {
      return;
    }
    emit(state.copyWith(currentStroke: current.copyWithPoint(point)));
    _requestRepaint();
  }

  /**
   * Finalizes the current stroke and adds it to the permanent stroke list.
   */
  void endStroke() {
    final current = state.currentStroke;
    if (current == null || current.points.isEmpty) return;
    emit(
      state.copyWith(
        strokes: [...state.strokes, current],
        clearCurrentStroke: true,
      ),
    );
    _requestRepaint();
  }

  /**
   * Removes the most recent stroke from the canvas and pushes it to the undo stack.
   */
  void undo() {
    if (state.strokes.isEmpty) return;
    final strokes = [...state.strokes];
    final removed = strokes.removeLast();
    emit(
      state.copyWith(
        strokes: strokes,
        undoStack: [...state.undoStack, removed],
      ),
    );
    _requestRepaint();
  }

  /**
   * Restores the most recently undone stroke from the undo stack.
   */
  void redo() {
    if (state.undoStack.isEmpty) return;
    final undoStack = [...state.undoStack];
    final restored = undoStack.removeLast();
    emit(
      state.copyWith(
        strokes: [...state.strokes, restored],
        undoStack: undoStack,
      ),
    );
    _requestRepaint();
  }

  /**
   * Clears all strokes from the canvas.
   */
  void clear() {
    emit(state.copyWith(strokes: [], clearCurrentStroke: true, undoStack: []));
    _requestRepaint();
  }

  /**
   * Updates the selected brush color for future strokes.
   */
  void setColor(Color color) => emit(
    state.copyWith(
      selectedColor: color,
      lastBrushColor: color,
      isEraser: false,
    ),
  );

  /**
   * Updates the selected brush width for future strokes.
   */
  void setWidth(double width) => emit(state.copyWith(selectedWidth: width));

  /**
   * Toggles the eraser tool using the current canvas [backgroundColor].
   */
  void toggleEraser(Color backgroundColor) {
    if (state.isEraser) {
      emit(
        state.copyWith(selectedColor: state.lastBrushColor, isEraser: false),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedColor: backgroundColor,
        lastBrushColor: state.selectedColor,
        isEraser: true,
      ),
    );
  }
}
