import 'package:dartz/dartz.dart';

abstract class AnswerRepository {
  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
  });

  Future<Either<String, Unit>> deleteQuestion({required String questionId});

  Future<Either<String, Unit>> archiveQuestion({required String questionId});

  Future<Either<String, Unit>> unarchiveQuestion({required String questionId});
}
