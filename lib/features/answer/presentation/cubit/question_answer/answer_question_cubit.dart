import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/answer/domain/usecase/answer_question_usecase.dart';
import 'answer_question_state.dart';

class AnswerQuestionCubit extends Cubit<AnswerQuestionState> {
  AnswerQuestionCubit(this._answerQuestionUseCase)
    : super(const AnswerQuestionState());

  final AnswerQuestionUseCase _answerQuestionUseCase;

  Future<void> answerQuestion({
    required String questionId,
    required String answerText,
  }) async {
    emit(const AnswerQuestionState(status: AnswerQuestionStatus.loading));
    final result = await _answerQuestionUseCase(
      questionId: questionId,
      answerText: answerText,
    );
    result.fold(
      (error) {
        emit(
          AnswerQuestionState(
            status: AnswerQuestionStatus.failure,
            errorMessage: error,
          ),
        );
      },
      (_) {
        emit(const AnswerQuestionState(status: AnswerQuestionStatus.success));
      },
    );
  }
}
