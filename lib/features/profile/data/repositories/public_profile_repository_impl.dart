import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/data/datasources/profile_datasource.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class PublicProfileRepositoryImpl implements PublicProfileRepository {
  final ProfileDataSource _dataSource;

  PublicProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, PublicProfile>> getPublicProfile(
    String userId,
    String? currentUserId,
  ) {
    return (_dataSource.getPublicProfile(userId, currentUserId));
  }

  @override
  Future<Either<String, PublicProfile>> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  ) async {
    return await _dataSource.getPublicProfileByUsername(
      username,
      currentUserId,
    );
  }

  @override
  Future<Either<String, List<AnsweredQuestion>>> getUserAnswers(
    String userId,
  ) async {
    final result = await _dataSource.getUserAnswers(userId);
    return result.map((answers) => answers.cast<AnsweredQuestion>());
  }
}
