import 'package:dartz/dartz.dart';
import 'package:vibi/features/follow/domain/entities/follower_user.dart';
import 'package:vibi/features/follow/domain/entities/following_user.dart';
import 'package:vibi/features/follow/data/datasources/follow_datasource.dart';
import 'package:vibi/features/follow/domain/repositories/follow_repository.dart';

class FollowRepositoryImpl implements FollowRepository {
  final FollowDataSource _dataSource;

  FollowRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, void>> followUser(
    String followerId,
    String followingId,
  ) async {
    return await _dataSource.followUser(followerId, followingId);
  }

  @override
  Future<Either<String, void>> unfollowUser(
    String followerId,
    String followingId,
  ) async {
    return await _dataSource.unfollowUser(followerId, followingId);
  }

  @override
  Future<Either<String, void>> removeFollower(
    String currentUserId,
    String followerId,
  ) async {
    return await _dataSource.removeFollower(currentUserId, followerId);
  }

  @override
  Future<Either<String, bool>> isFollowing(
    String followerId,
    String followingId,
  ) async {
    return (await _dataSource.isFollowing(followerId, followingId));
  }

  @override
  Future<Either<String, List<FollowerUser>>> getFollowers(String userId) async {
    final result = await _dataSource.getFollowers(userId);
    return result.map((followers) => followers.cast<FollowerUser>());
  }

  @override
  Future<Either<String, List<FollowingUser>>> getFollowing(
    String userId,
  ) async {
    final result = await _dataSource.getFollowing(userId);
    return result.map((following) => following.cast<FollowingUser>());
  }
}
