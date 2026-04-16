import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class ArchiveQuestionUseCase {
  const ArchiveQuestionUseCase(this._repository);

  final InboxRepository _repository;

  Future<Either<String, Unit>> call({required String questionId}) {
    return _repository.archiveQuestion(questionId: questionId);
  }

  Future<Either<String, Unit>> unarchive({required String questionId}) {
    return _repository.unarchiveQuestion(questionId: questionId);
  }
}
