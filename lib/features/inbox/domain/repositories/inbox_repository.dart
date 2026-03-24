import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

abstract class InboxRepository {
  Future<List<InboxQuestion>> getPendingQuestions();

  Future<void> answerQuestion({
    required String questionId,
    required String answerText,
  });

  Future<void> deleteQuestion(String questionId);
}
