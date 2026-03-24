class FollowingUser {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final DateTime followedAt;

  FollowingUser({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.followersCount,
    required this.followedAt,
  });
}
