import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

/**
 * Use case for answering questions.
 */
class AnswerQuestionUseCase {
  const AnswerQuestionUseCase(this._repository);

  final InboxRepository _repository;

  /**
   * Executes the use case by calling [answerQuestion] on the [InboxRepository].
   *
   * [questionId] is the unique identifier of the question being answered.
   * [answerText] is the content of the answer provided by the user.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] if the action fails.
   */
  Future<Either<String, Unit>> call({
    required String questionId,
    required String answerText,
  }) {
    return _repository.answerQuestion(
      questionId: questionId,
      answerText: answerText,
    );
  }
}
