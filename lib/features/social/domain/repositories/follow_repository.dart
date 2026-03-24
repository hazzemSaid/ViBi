abstract class FollowRepository {
  Future<void> followUser(String followerId, String followingId);
  Future<void> unfollowUser(String followerId, String followingId);
  Future<void> removeFollower(String currentUserId, String followerId);
  Future<void> requestFollow(String requesterId, String targetId);
  Future<void> respondToRequest(String requestId, bool accept);
  Future<bool> isFollowing(String followerId, String followingId);
}
