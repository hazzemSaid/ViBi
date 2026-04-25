import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

/**
 * Use case responsible for fetching pending or filtered questions for the inbox.
 */
class GetPendingQuestionsUseCase {
  const GetPendingQuestionsUseCase(this._repository);

  final InboxRepository _repository;

  /**
   * Retrieves a list of questions based on limit, offset, and status.
   *
   * [limit] defines the page size.
   * [offset] defines the pagination skip count.
   * [status] filters by the question's state.
   *
   * Returns:
   * - [Right] containing a [List] of [InboxQuestion] on success.
   * - [Left] containing an error [String] on failure.
   */
  Future<Either<String, List<InboxQuestion>>> call({
    required int limit,
    required int offset,
    String? status,
  }) {
    return _repository.getPendingQuestions(
      limit: limit,
      offset: offset,
      status: status ?? 'pending',
    );
  }
}

/**
 * Use case responsible for moving questions between the active inbox and the archive.
 *
 * This handles both archiving (hiding) and unarchiving (restoring) actions.
 */
class ArchiveQuestionUseCase {
  const ArchiveQuestionUseCase(this._repository);

  final InboxRepository _repository;

  /**
   * Archives a specific question, moving it out of the primary inbox view.
   *
   * [questionId] is the unique identifier of the question to archive.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] if the action fails.
   */
  Future<Either<String, Unit>> call({required String questionId}) {
    return _repository.archiveQuestion(questionId: questionId);
  }

  /**
   * Restores an archived question back to the active inbox.
   *
   * [questionId] is the unique identifier of the question to unarchive.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] if the action fails.
   */
  Future<Either<String, Unit>> unarchive({required String questionId}) {
    return _repository.unarchiveQuestion(questionId: questionId);
  }
}
