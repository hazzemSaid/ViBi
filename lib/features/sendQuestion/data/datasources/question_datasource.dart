import 'package:dartz/dartz.dart';
import 'package:vibi/features/sendQuestion/data/models/send_question_dto.dart';

abstract class QuestionDataSource {
  Future<Either<String, void>> sendQuestion(SendQuestionDto dto);
}
