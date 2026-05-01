import 'package:dartz/dartz.dart';
import 'package:vibi/features/answer/data/models/answer_action_dto.dart';

abstract class AnswerDataSource {
  Future<Either<String, Unit>> handleQuestionAction(AnswerActionDto dto);
}
