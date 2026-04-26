import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/inbox/domain/usecases/archive_question_usecase.dart';
import 'package:vibi/features/inbox/presentation/view/archive_question_cubit/archive_question_state.dart';

class ArchiveQuestionCubit extends Cubit<ArchiveQuestionState> {
  ArchiveQuestionCubit({required this.archiveQuestionUseCase})
    : super(ArchiveQuestionInitial());
  final ArchiveQuestionUseCase archiveQuestionUseCase;

  Future<void> archiveQuestion(String questionId) async {
    emit(ArchiveQuestionLoading());
    final result = await archiveQuestionUseCase(questionId: questionId);
    result.fold(
      (error) => emit(ArchiveQuestionFailure(message: error)),
      (_) => emit(ArchiveQuestionSuccess()),
    );
  }

  Future<void> unarchiveQuestion(String questionId) async {
    emit(ArchiveQuestionLoading());
    final result = await archiveQuestionUseCase.unarchive(
      questionId: questionId,
    );
    result.fold(
      (error) => emit(ArchiveQuestionFailure(message: error)),
      (_) => emit(ArchiveQuestionSuccess()),
    );
  }
}
