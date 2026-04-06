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
    final avatarUrls = _parseAvatarUrls(profileNode['avatar_urls']);

    return FollowerUserModel(
      id: node['follower_id'] as String? ?? '',
      username: profileNode['username'] as String?,
      fullName: profileNode['full_name'] as String?,
      avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
      bio: profileNode['bio'] as String?,
      followersCount: _extractCount(
        profileNode['followersCount'],
        fallback: profileNode['followers_count'],
      ),
      followedAt: DateTime.parse(node['created_at'] as String),
    );
  }

  static List<String> _parseAvatarUrls(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) return [value];
    return const [];
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
