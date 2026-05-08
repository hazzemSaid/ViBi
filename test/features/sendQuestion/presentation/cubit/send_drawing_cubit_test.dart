import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibi/features/sendQuestion/domain/usecases/send_drawing_question.dart';
import 'package:vibi/features/sendQuestion/presentation/cubit/send_drawing_cubit.dart';

class MockSendDrawingQuestion extends Mock implements SendDrawingQuestion {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('SendDrawingCubit', () {
    late SendDrawingQuestion mockSendDrawingQuestion;
    late SendDrawingCubit sendDrawingCubit;

    setUp(() {
      mockSendDrawingQuestion = MockSendDrawingQuestion();
      sendDrawingCubit = SendDrawingCubit(mockSendDrawingQuestion);
    });

    tearDown(() {
      sendDrawingCubit.close();
    });

    test('initial state is correct', () {
      expect(sendDrawingCubit.state, SendDrawingInitial());
    });

    final pngBytes = Uint8List.fromList([1, 2, 3]);

    blocTest<SendDrawingCubit, SendDrawingState>(
      'send emits [Loading, Success] when successful',
      build: () {
        when(() => mockSendDrawingQuestion(
              recipientId: any(named: 'recipientId'),
              pngBytes: any(named: 'pngBytes'),
              isAnonymous: any(named: 'isAnonymous'),
              senderId: any(named: 'senderId'),
            )).thenAnswer((_) async => 'https://example.com/drawing.png');
        return sendDrawingCubit;
      },
      act: (cubit) => cubit.send(
        recipientId: 'recipient_1',
        pngBytes: pngBytes,
        isAnonymous: false,
        senderId: 'sender_1',
      ),
      expect: () => [
        SendDrawingLoading(),
        const SendDrawingSuccess('https://example.com/drawing.png'),
      ],
      verify: (_) {
        verify(() => mockSendDrawingQuestion(
              recipientId: 'recipient_1',
              pngBytes: pngBytes,
              isAnonymous: false,
              senderId: 'sender_1',
            )).called(1);
      },
    );

    blocTest<SendDrawingCubit, SendDrawingState>(
      'send emits [Loading, Failure] when an error occurs',
      build: () {
        when(() => mockSendDrawingQuestion(
              recipientId: any(named: 'recipientId'),
              pngBytes: any(named: 'pngBytes'),
              isAnonymous: any(named: 'isAnonymous'),
              senderId: any(named: 'senderId'),
            )).thenThrow(Exception('Upload failed'));
        return sendDrawingCubit;
      },
      act: (cubit) => cubit.send(
        recipientId: 'recipient_1',
        pngBytes: pngBytes,
        isAnonymous: false,
      ),
      expect: () => [
        SendDrawingLoading(),
        const SendDrawingFailure('Exception: Upload failed'),
      ],
    );

    blocTest<SendDrawingCubit, SendDrawingState>(
      'reset emits SendDrawingInitial',
      build: () => sendDrawingCubit,
      act: (cubit) => cubit.reset(),
      expect: () => [SendDrawingInitial()],
    );
  });
}
