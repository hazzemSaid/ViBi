import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

/**
 * Implementation of [InboxRepository] that uses [GraphQLInboxDataSource] to fetch and manage inbox data.
 */
class InboxRepositoryImpl implements InboxRepository {
  final GraphQLInboxDataSource _dataSource;

  /**
   * Initializes the [InboxRepositoryImpl] with the provided [_dataSource].
   */
  InboxRepositoryImpl(this._dataSource);

  /**
   * Helper to fetch the current authenticated user's ID.
   */
  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  /**
   * Fetches pending questions for the current authenticated user.
   *
   * [limit] is the page size for fetching questions.
   * [offset] is the number of items to skip.
   * [status] is the desired question status to filter by.
   *
   * Returns:
   * - [Right] with a list of [InboxQuestion] on success.
   * - [Left] with an error message on failure.
   */
  Future<Either<String, List<InboxQuestion>>> getPendingQuestions({
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) async {
    return _dataSource.getPendingQuestions(
      _currentUserId,
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  @override
  /**
   * Answers a specific question by delegating to the data source.
   *
   * [questionId] is the unique ID of the question.
   * [answerText] is the content of the answer.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error message on failure.
   */
  Future<Either<String, Unit>> answerQuestion({
    required String questionId,
    required String answerText,
  }) async {
    return _dataSource.answerQuestion(
      questionId: questionId,
      answerText: answerText,
      userId: _currentUserId,
    );
  }

  @override
  /**
   * Permanently deletes a question via the data source.
   *
   * [questionId] is the ID of the question to delete.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error message on failure.
   */
  Future<Either<String, Unit>> deleteQuestion({
    required String questionId,
  }) async {
    return _dataSource.deleteQuestion(questionId);
  }

  @override
  /**
   * Archives a question via the data source.
   *
   * [questionId] is the ID of the question to archive.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error message on failure.
   */
  Future<Either<String, Unit>> archiveQuestion({
    required String questionId,
  }) async {
    return _dataSource.archiveQuestion(questionId: questionId);
  }

  @override
  /**
   * Unarchives a question via the data source.
   *
   * [questionId] is the ID of the question to unarchive.
   *
   * Returns:
   * - [Right] with [Unit] on success.
   * - [Left] with an error message on failure.
   */
  Future<Either<String, Unit>> unarchiveQuestion({
    required String questionId,
  }) async {
    return _dataSource.unarchiveQuestion(questionId: questionId);
  }
}

