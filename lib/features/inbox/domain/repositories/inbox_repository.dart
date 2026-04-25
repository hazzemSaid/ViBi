import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

/**
 * Abstract repository defining the contract for inbox operations.
 */
abstract class InboxRepository {
  /**
   * Fetches a list of questions filtered by status and pagination.
   *
   * [limit] is the maximum number of items to retrieve.
   * [offset] is the number of items to skip.
   * [status] is the filter for question state.
   *
   * Returns:
   * - [Right] with [List<InboxQuestion>] on success.
   * - [Left] with an error [String] on failure.
   */
  Future<Either<String, List<InboxQuestion>>> getPendingQuestions({
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  });

  /**
   * Submits an answer content for the specified question.
   *
   * [questionId] is the target question ID.
   * [answerText] is the response content.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] on failure.
   */
  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
  });

  /**
   * Permanently deletes the specified question.
   *
   * [questionId] is the target question ID to be removed.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] on failure.
   */
  Future<Either<String, Unit>> deleteQuestion({required String questionId});

  /**
   * Moves a question to the archive so it's hidden from the primary inbox.
   *
   * [questionId] is the target question ID.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] on failure.
   */
  Future<Either<String, Unit>> archiveQuestion({required String questionId});

  /**
   * Restores a question from the archive back to the active inbox.
   *
   * [questionId] is the target question ID.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error [String] on failure.
   */
  Future<Either<String, Unit>> unarchiveQuestion({required String questionId});
}
