import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/answer/domain/usecase/answer_question_usecase.dart';
import 'package:vibi/features/answer/presentation/cubit/question_answer/answer_question_cubit.dart';
import 'package:vibi/features/answer/presentation/cubit/question_answer/answer_question_state.dart';

class _FakeAnswerQuestionUseCase implements AnswerQuestionUseCase {
  bool callCalled = false;
  String? lastQuestionId;
  String? lastAnswerText;
  bool shouldFail = false;
  String errorMessage = 'answer failed';

  @override
  Future<Either<String, Unit>> call({
    required String questionId,
    required String answerText,
  }) async {
    callCalled = true;
    lastQuestionId = questionId;
    lastAnswerText = answerText;
    if (shouldFail) {
      return Left(errorMessage);
    }
    return Right(unit);
  }
}

void main() {
  group('AnswerQuestionCubit', () {
    test('initial state is initial', () {
      final useCase = _FakeAnswerQuestionUseCase();
      final cubit = AnswerQuestionCubit(useCase);

      expect(cubit.state.status, AnswerQuestionStatus.initial);
      expect(cubit.state.errorMessage, isNull);

      cubit.close();
    });

    test('answerQuestion emits success when use case succeeds', () async {
      final useCase = _FakeAnswerQuestionUseCase();
      final cubit = AnswerQuestionCubit(useCase);

      await cubit.answerQuestion(
        questionId: 'q-1',
        answerText: 'My answer',
      );

      expect(cubit.state.status, AnswerQuestionStatus.success);
      expect(useCase.callCalled, isTrue);
      expect(useCase.lastQuestionId, 'q-1');
      expect(useCase.lastAnswerText, 'My answer');

      cubit.close();
    });

    test('answerQuestion emits failure when use case fails', () async {
      final useCase = _FakeAnswerQuestionUseCase()..shouldFail = true;
      final cubit = AnswerQuestionCubit(useCase);

      await cubit.answerQuestion(
        questionId: 'q-1',
        answerText: 'My answer',
      );

      expect(cubit.state.status, AnswerQuestionStatus.failure);
      expect(cubit.state.errorMessage, 'answer failed');

      cubit.close();
    });

    test('answerQuestion emits loading then final state', () async {
      final useCase = _FakeAnswerQuestionUseCase();
      final cubit = AnswerQuestionCubit(useCase);
      final states = <AnswerQuestionState>[];
      cubit.stream.listen(states.add);

      await cubit.answerQuestion(
        questionId: 'q-1',
        answerText: 'My answer',
      );
      await Future<void>.delayed(Duration.zero);

      expect(states.any((s) => s.status == AnswerQuestionStatus.loading), isTrue);
      expect(states.any((s) => s.status == AnswerQuestionStatus.success), isTrue);

      cubit.close();
    });
  });
}
