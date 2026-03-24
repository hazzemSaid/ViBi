import 'package:vibi/features/profile/domain/entities/following_user.dart';

class FollowingUserModel extends FollowingUser {
  FollowingUserModel({
    required super.id,
    super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    required super.followersCount,
    required super.followedAt,
  });

  factory FollowingUserModel.fromGraphQL(Map<String, dynamic> node) {
    final profileNode =
        node['following_profile'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    return FollowingUserModel(
      id: node['following_id'] as String? ?? '',
      username: profileNode['username'] as String?,
      fullName: profileNode['full_name'] as String?,
      avatarUrl: profileNode['avatar_url'] as String?,
      bio: profileNode['bio'] as String?,
      followersCount: profileNode['followers_count'] as int? ?? 0,
      followedAt: DateTime.parse(node['created_at'] as String),
    );
  }
}
