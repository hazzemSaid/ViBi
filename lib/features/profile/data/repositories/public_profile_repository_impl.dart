import 'package:vibi/features/profile/data/sources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class PublicProfileRepositoryImpl implements PublicProfileRepository {
  final GraphQLProfileDataSource _dataSource;

  PublicProfileRepositoryImpl(this._dataSource);

  @override
  Future<PublicProfile?> getPublicProfile(
    String userId,
    String? currentUserId,
  ) async {
    return await _dataSource.getPublicProfile(userId, currentUserId);
  }

  @override
  Future<PublicProfile?> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  ) async {
    return await _dataSource.getPublicProfileByUsername(username, currentUserId);
  }

  @override
  Future<List<AnsweredQuestion>> getUserAnswers(String userId) async {
    return await _dataSource.getUserAnswers(userId);
  }
}
