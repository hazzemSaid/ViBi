import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/inbox/data/datasources/inbox_datasource.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

/**
 * Implementation of [InboxRepository] that uses [InboxDataSource] to fetch inbox data.
 */
class InboxRepositoryImpl implements InboxRepository {
  final InboxDataSource _dataSource;

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
  @override
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
}

