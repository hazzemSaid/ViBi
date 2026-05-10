import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:vibi/features/sendQuestion/presentation/cubit/drawing_cubit.dart';

void main() {
  group('DrawingCubit', () {
    test('initial state is correct', () {
      final cubit = DrawingCubit();
      expect(cubit.state, const DrawingState());
      cubit.close();
    });

    blocTest<DrawingCubit, DrawingState>(
      'startStroke emits state with currentStroke',
      build: () => DrawingCubit(),
      act: (cubit) => cubit.startStroke(const Offset(10, 10)),
      expect: () => [
        DrawingState(
          currentStroke: Stroke(
            points: [const Offset(10, 10)],
            color: const Color(0xFF000000),
            width: 4.0,
          ),
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'endStroke persists the stroke after continueStroke',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.continueStroke(const Offset(20, 20));
        cubit.endStroke();
      },
      skip: 2,
      expect: () => [
        DrawingState(
          strokes: [
            Stroke(
              points: [const Offset(10, 10), const Offset(20, 20)],
              color: const Color(0xFF000000),
              width: 4.0,
            ),
          ],
          currentStroke: null,
          undoStack: [],
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'startStroke clears redo stack after undo',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.endStroke();
        cubit.undo();
        cubit.startStroke(const Offset(20, 20));
      },
      skip: 3,
      expect: () => [
        DrawingState(
          currentStroke: Stroke(
            points: [const Offset(20, 20)],
            color: const Color(0xFF000000),
            width: 4.0,
          ),
          undoStack: [],
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'endStroke adds currentStroke to strokes list',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.endStroke();
      },
      skip: 1,
      expect: () => [
        DrawingState(
          strokes: [
            Stroke(
              points: [const Offset(10, 10)],
              color: const Color(0xFF000000),
              width: 4.0,
            ),
          ],
          currentStroke: null,
          undoStack: [],
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'undo removes last stroke and pushes it to undoStack',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.endStroke();
        cubit.undo();
      },
      skip: 2,
      expect: () => [
        DrawingState(
          strokes: [],
          currentStroke: null,
          undoStack: [
            Stroke(
              points: [const Offset(10, 10)],
              color: const Color(0xFF000000),
              width: 4.0,
            ),
          ],
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'redo restores last undone stroke from undoStack',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.endStroke();
        cubit.undo();
        cubit.redo();
      },
      skip: 3,
      expect: () => [
        DrawingState(
          strokes: [
            Stroke(
              points: [const Offset(10, 10)],
              color: const Color(0xFF000000),
              width: 4.0,
            ),
          ],
          currentStroke: null,
          undoStack: [],
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'clear removes all strokes and clears undoStack',
      build: () => DrawingCubit(),
      act: (cubit) {
        cubit.startStroke(const Offset(10, 10));
        cubit.endStroke();
        cubit.clear();
      },
      skip: 2,
      expect: () => [
        const DrawingState(strokes: [], undoStack: []),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'setColor updates selectedColor and lastBrushColor',
      build: () => DrawingCubit(),
      act: (cubit) => cubit.setColor(const Color(0xFFFF0000)),
      expect: () => [
        const DrawingState(
          selectedColor: Color(0xFFFF0000),
          lastBrushColor: Color(0xFFFF0000),
        ),
      ],
    );

    blocTest<DrawingCubit, DrawingState>(
      'setWidth updates selectedWidth',
      build: () => DrawingCubit(),
      act: (cubit) => cubit.setWidth(8.0),
      expect: () => [
        const DrawingState(selectedWidth: 8.0),
      ],
    );
  });
}
