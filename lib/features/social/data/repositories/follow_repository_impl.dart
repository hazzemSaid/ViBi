import 'package:vibi/features/social/data/datasources/graphql_follow_datasource.dart';
import 'package:vibi/features/social/domain/repositories/follow_repository.dart';

class FollowRepositoryImpl implements FollowRepository {
  final GraphQLFollowDataSource _dataSource;

  FollowRepositoryImpl(this._dataSource);

  @override
  Future<void> followUser(String followerId, String followingId) async {
    await _dataSource.followUser(followerId, followingId);
  }

  @override
  Future<void> unfollowUser(String followerId, String followingId) async {
    await _dataSource.unfollowUser(followerId, followingId);
  }

  @override
  Future<void> removeFollower(String currentUserId, String followerId) async {
    await _dataSource.removeFollower(currentUserId, followerId);
  }

  @override
  Future<void> requestFollow(String requesterId, String targetId) async {
    await _dataSource.requestFollow(requesterId, targetId);
  }

  @override
  Future<void> respondToRequest(String requestId, bool accept) async {
    // Note: This method signature needs additional parameters in the interface
    throw UnimplementedError('Use respondToRequestWithDetails instead');
  }

  Future<void> respondToRequestWithDetails(
    String requestId,
    bool accept,
    String targetId,
    String requesterId,
  ) async {
    await _dataSource.respondToRequest(
      requestId,
      accept,
      targetId,
      requesterId,
    );
  }

  @override
  Future<bool> isFollowing(String followerId, String followingId) async {
    return await _dataSource.isFollowing(followerId, followingId);
  }
}
