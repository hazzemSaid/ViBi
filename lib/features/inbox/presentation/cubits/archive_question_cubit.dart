import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/inbox/domain/usecases/archive_question_usecase.dart';
import 'package:vibi/features/inbox/presentation/state/archive_question_state.dart';

class ArchiveQuestionCubit extends Cubit<ArchiveQuestionState> {
  ArchiveQuestionCubit({required this.archivequestionUseCase})
    : super(ArchiveQuestionInitial());
  final ArchiveQuestionUseCase archivequestionUseCase;

  Future<void> archiveQuestion(String questionId) async {
    emit(ArchiveQuestionLoading());
    try {
      await archivequestionUseCase(questionId: questionId);
      emit(ArchiveQuestionSuccess());
    } catch (e) {
      emit(ArchiveQuestionFailure(message: e.toString()));
    }
  }

  Future<void> unarchiveQuestion(String questionId) async {
    emit(ArchiveQuestionLoading());
    try {
      await archivequestionUseCase.unarchive(questionId: questionId);
      emit(ArchiveQuestionSuccess());
    } catch (e) {
      emit(ArchiveQuestionFailure(message: e.toString()));
    }
  }
}
