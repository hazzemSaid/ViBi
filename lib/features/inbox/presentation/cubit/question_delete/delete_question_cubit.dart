import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/answer/domain/usecase/delete_question_usecase.dart';
import 'delete_question_state.dart';

class DeleteQuestionCubit extends Cubit<DeleteQuestionState> {
  DeleteQuestionCubit(this._deleteQuestionUseCase)
    : super(const DeleteQuestionState());

  final DeleteQuestionUseCase _deleteQuestionUseCase;

  Future<void> deleteQuestion(String questionId) async {
    emit(const DeleteQuestionState(status: DeleteQuestionStatus.loading));
    final result = await _deleteQuestionUseCase(questionId);
    result.fold(
      (error) {
        emit(
          DeleteQuestionState(
            status: DeleteQuestionStatus.failure,
            errorMessage: error,
          ),
        );
      },
      (_) {
        emit(const DeleteQuestionState(status: DeleteQuestionStatus.success));
      },
    );
  }
}
