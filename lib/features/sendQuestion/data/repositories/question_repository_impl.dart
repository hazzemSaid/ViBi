import 'package:dartz/dartz.dart';
import 'package:vibi/features/sendQuestion/data/datasources/question_datasource.dart';
import 'package:vibi/features/sendQuestion/data/models/send_question_dto.dart';
import 'package:vibi/features/sendQuestion/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionDataSource _dataSource;

  QuestionRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, void>> sendQuestion({
    required String recipientId,
    required String questionText,
    required bool isAnonymous,
    String? senderId,
  }) async {
    return await _dataSource.sendQuestion(
      SendQuestionDto(
        recipientId: recipientId,
        questionText: questionText,
        isAnonymous: isAnonymous,
        senderId: senderId,
      ),
    );
  }
}
