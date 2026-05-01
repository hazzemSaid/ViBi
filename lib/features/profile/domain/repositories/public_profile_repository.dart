import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';

abstract class PublicProfileRepository {
  Future<Either<String, PublicProfile>> getPublicProfile(
    String userId,
    String? currentUserId,
  );
  Future<Either<String, PublicProfile>> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  );
  Future<Either<String, List<AnsweredQuestion>>> getUserAnswers(
    String userId,
  );
}
