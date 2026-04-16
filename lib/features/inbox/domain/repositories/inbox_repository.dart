import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

abstract class InboxRepository {
  Future<Either<String, List<InboxQuestion>>> getPendingQuestions({
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  });

  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
  });

  Future<Either<String, Unit>> deleteQuestion({required String questionId});
  Future<Either<String, Unit>> archiveQuestion({required String questionId});
  Future<Either<String, Unit>> unarchiveQuestion({required String questionId});
}
