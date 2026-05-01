import 'package:dartz/dartz.dart';
import 'package:vibi/features/answer/domain/repositories/answer_repository.dart';

/**
 * Use case for deleting questions.
 */
class DeleteQuestionUseCase {
  const DeleteQuestionUseCase(this._repository);

  final AnswerRepository _repository;

  /**
   * Deletes a specific question.
   */
  Future<Either<String, Unit>> call(String questionId) {
    return _repository.deleteQuestion(questionId: questionId);
  }
}
