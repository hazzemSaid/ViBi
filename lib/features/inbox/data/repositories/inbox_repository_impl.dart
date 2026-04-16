import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class InboxRepositoryImpl implements InboxRepository {
  final GraphQLInboxDataSource _dataSource;
  final String _currentUserId;

  InboxRepositoryImpl(this._dataSource, this._currentUserId);

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

  @override
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
  Future<Either<String, Unit>> deleteQuestion({
    required String questionId,
  }) async {
    return _dataSource.deleteQuestion(questionId);
  }

  @override
  Future<Either<String, Unit>> archiveQuestion({
    required String questionId,
  }) async {
    return _dataSource.archiveQuestion(questionId: questionId);
  }
}
