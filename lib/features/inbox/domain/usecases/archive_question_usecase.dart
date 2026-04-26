import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

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
