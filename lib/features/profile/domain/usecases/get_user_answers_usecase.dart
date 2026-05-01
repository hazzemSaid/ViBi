import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class GetUserAnswersUseCase {
  final PublicProfileRepository _repository;

  GetUserAnswersUseCase(this._repository);

  Future<Either<String, List<AnsweredQuestion>>> call(String userId) async {
    return _repository.getUserAnswers(userId);
  }
}
