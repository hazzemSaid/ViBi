import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class AnswerQuestionUseCase {
  const AnswerQuestionUseCase(this._repository);

  final InboxRepository _repository;

  Future<Either<String, Unit>> call({
    required String questionId,
    required String answerText,
  }) {
    return _repository.answerQuestion(
      questionId: questionId,
      answerText: answerText,
    );
  }
}
