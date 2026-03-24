import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/questions/domain/repositories/question_repository.dart';

class SendQuestionCubit extends Cubit<ViewState<void>> {
  SendQuestionCubit(this._repository) : super(const ViewState());
  final QuestionRepository _repository;

  Future<void> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      await _repository.sendQuestion(
        recipientId: recipientId,
        questionText: questionText,
        isAnonymous: isAnonymous,
        senderId: isAnonymous ? null : currentUserId,
      );
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

QuestionRepository get questionRepository => getIt<QuestionRepository>();
