import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/questions/domain/repositories/question_repository.dart';
import 'package:vibi/features/questions/presentation/providers/question_state.dart';

class SendQuestionCubit extends Cubit<SendQuestionState> {
  SendQuestionCubit(this._repository) : super(const SendQuestionInitial());
  final QuestionRepository _repository;

  Future<void> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    emit(const SendQuestionLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      await _repository.sendQuestion(
        recipientId: recipientId,
        questionText: questionText,
        isAnonymous: isAnonymous,
        senderId: isAnonymous ? null : currentUserId,
      );
      emit(const SendQuestionSuccess());
    } catch (e) {
      emit(SendQuestionFailure('$e'));
    }
  }
}
