import 'package:vibi/features/inbox/data/datasources/graphql_inbox_datasource.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class InboxRepositoryImpl implements InboxRepository {
  final GraphQLInboxDataSource _dataSource;
  final String _currentUserId;

  InboxRepositoryImpl(this._dataSource, this._currentUserId);

  @override
  Future<List<InboxQuestion>> getPendingQuestions() async {
    return await _dataSource.getPendingQuestions(_currentUserId);
  }

  @override
  Future<void> answerQuestion({
    required String questionId,
    required String answerText,
  }) async {
    await _dataSource.answerQuestion(
      questionId: questionId,
      answerText: answerText,
      userId: _currentUserId,
    );
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    await _dataSource.deleteQuestion(questionId);
  }
}
