import 'package:dartz/dartz.dart';
import 'package:vibi/features/follow/data/models/follower_user_model.dart';
import 'package:vibi/features/follow/data/models/following_user_model.dart';

abstract class FollowDataSource {
  Future<Either<String, void>> followUser(
    String followerId,
    String followingId,
  );

  Future<Either<String, void>> unfollowUser(
    String followerId,
    String followingId,
  );

  Future<Either<String, void>> removeFollower(
    String currentUserId,
    String followerId,
  );

  Future<Either<String, bool>> isFollowing(
    String followerId,
    String followingId,
  );

  Future<Either<String, List<FollowerUserModel>>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Either<String, List<FollowingUserModel>>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  });
}
