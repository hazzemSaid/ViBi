import 'package:dartz/dartz.dart';
import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/inbox/domain/repositories/inbox_repository.dart';

class GetPendingQuestionsUseCase {
  const GetPendingQuestionsUseCase(this._repository);

  final InboxRepository _repository;

  Future<Either<String, List<InboxQuestion>>> call({
    int limit = 20,
    int offset = 0,
    String status = 'pending',
  }) {
    return _repository.getPendingQuestions(
      limit: limit,
      offset: offset,
      status: status,
    );
  }
}
