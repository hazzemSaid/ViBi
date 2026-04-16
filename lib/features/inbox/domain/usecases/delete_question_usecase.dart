import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class DeleteQuestionUseCase {
  const DeleteQuestionUseCase(this._repository);

  final InboxRepository _repository;

  Future<Either<String, Unit>> call(String questionId) {
    return _repository.deleteQuestion(questionId: questionId);
  }
}
