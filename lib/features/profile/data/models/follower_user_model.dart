import 'package:vibi/features/profile/domain/entities/follower_user.dart';

class FollowerUserModel extends FollowerUser {
  FollowerUserModel({
    required super.id,
    super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    required super.followersCount,
    required super.followedAt,
  });

  factory FollowerUserModel.fromGraphQL(Map<String, dynamic> node) {
    final profileNode =
        node['follower'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return FollowerUserModel(
      id: node['follower_id'] as String? ?? '',
      username: profileNode['username'] as String?,
      fullName: profileNode['full_name'] as String?,
      avatarUrl: profileNode['avatar_url'] as String?,
      bio: profileNode['bio'] as String?,
      followersCount: profileNode['followers_count'] as int? ?? 0,
      followedAt: DateTime.parse(node['created_at'] as String),
    );
  }
}
