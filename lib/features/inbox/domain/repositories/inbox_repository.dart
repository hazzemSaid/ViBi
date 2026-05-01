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
}
