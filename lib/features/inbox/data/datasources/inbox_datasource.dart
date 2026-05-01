import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/data/models/inbox_question_model.dart';

abstract class InboxDataSource {
  Future<Either<String, List<InboxQuestionModel>>> getPendingQuestions(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  });
}
