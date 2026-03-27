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
      followersCount: _extractCount(
        profileNode['followersCount'],
        fallback: profileNode['followers_count'],
      ),
      followedAt: DateTime.parse(node['created_at'] as String),
    );
  }

  static int _extractCount(dynamic value, {dynamic fallback}) {
    if (value is int) return value;
    if (value is Map<String, dynamic>) {
      final total = value['totalCount'];
      if (total is int) return total;
      final edges = value['edges'];
      if (edges is List) return edges.length;
      return 0;
    }
    if (fallback is int) return fallback;
    return 0;
  }
}
