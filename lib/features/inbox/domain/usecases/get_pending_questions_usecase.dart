import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

/**
 * Use case responsible for retrieving a list of pending or filtered questions for the inbox.
 */
class GetPendingQuestionsUseCase {
  const GetPendingQuestionsUseCase(this._repository);

  final InboxRepository _repository;

  /**
   * Executes the use case by calling [getPendingQuestions] on the [InboxRepository].
   *
   * [limit] specifies the maximum number of questions to return (defaults to 20).
   * [offset] specifies the number of questions to skip for pagination (defaults to 0).
   * [status] filters questions by their state (e.g., 'pending', 'archived').
   *
   * Returns:
   * - [Right] containing a [List] of [InboxQuestion] on success.
   * - [Left] containing an error [String] if the request fails.
   */
  Future<Either<String, List<InboxQuestion>>> call({
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) {
    return _repository.getPendingQuestions(
      limit: limit,
      offset: offset,
      status: status,
    );
  }
}
