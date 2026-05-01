import 'package:dartz/dartz.dart';
import 'package:vibi/features/follow/domain/entities/follower_user.dart';
import 'package:vibi/features/follow/domain/entities/following_user.dart';

abstract class FollowRepository {
  /** Creates a follow relationship between two users. */
  Future<Either<String, void>> followUser(
    String followerId,
    String followingId,
  );
  /** Removes a follow relationship between two users. */
  Future<Either<String, void>> unfollowUser(
    String followerId,
    String followingId,
  );
  /** Removes one follower from the current user. */
  Future<Either<String, void>> removeFollower(
    String currentUserId,
    String followerId,
  );
  /** Checks whether followerId currently follows followingId. */
  Future<Either<String, bool>> isFollowing(
    String followerId,
    String followingId,
  );
  /** Fetches followers list for a user. */
  Future<Either<String, List<FollowerUser>>> getFollowers(String userId);
  /** Fetches following list for a user. */
  Future<Either<String, List<FollowingUser>>> getFollowing(String userId);
}
