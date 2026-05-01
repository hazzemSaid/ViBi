import 'package:vibi/features/sendQuestion/data/datasources/graphql_question_datasource.dart';
import 'package:vibi/features/sendQuestion/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final GraphQLQuestionDataSource _dataSource;

  QuestionRepositoryImpl(this._dataSource);

  @override
  Future<void> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
    String? senderId,
  }) async {
    await _dataSource.sendQuestion(
      recipientId: recipientId,
      questionText: questionText,
      isAnonymous: isAnonymous,
      senderId: senderId,
    );
  }
}
