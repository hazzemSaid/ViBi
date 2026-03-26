import 'package:vibi/features/profile/domain/entities/public_profile.dart';

class PublicProfileModel extends PublicProfile {
  PublicProfileModel({
    required super.id,
    super.name,
    super.username,
    super.bio,
    super.profileImageUrl,
    required super.followersCount,
    required super.followingCount,
    required super.answersCount,
    required super.isPrivate,
    required super.isFollowing,
    required super.hasRequestedFollow,
    required super.canViewContent,
    super.allowAnonymousQuestions,
    super.publicProfileEnabled,
    super.publicThemeKey,
    super.publicCtaText,
    super.updatedAt,
  });

  factory PublicProfileModel.fromGraphQL(
    Map<String, dynamic> node, {
    bool isFollowing = false,
    bool hasRequestedFollow = false,
  }) {
    final isPrivate = node['is_private'] as bool? ?? false;
    final canViewContent = !isPrivate || isFollowing;

    return PublicProfileModel(
      id: node['id'] as String,
      name: node['full_name'] as String?,
      username: node['username'] as String?,
      bio: node['bio'] as String?,
      profileImageUrl: node['avatar_url'] as String?,
      followersCount: _extractCount(
        node['followersCount'],
        fallback: node['followers_count'],
      ),
      followingCount: _extractCount(
        node['followingCount'],
        fallback: node['following_count'],
      ),
      answersCount: _extractCount(
        node['answersCount'],
        fallback: node['answers_count'],
      ),
      isPrivate: isPrivate,
      isFollowing: isFollowing,
      hasRequestedFollow: hasRequestedFollow,
      canViewContent: canViewContent,
      allowAnonymousQuestions:
          node['allow_anonymous_questions'] as bool? ?? true,
      publicProfileEnabled: node['public_profile_enabled'] as bool? ?? true,
      publicThemeKey: node['public_theme_key'] as String? ?? 'tellonym_dark',
      publicCtaText: node['public_cta_text'] as String?,
      updatedAt: node['updated_at'] != null
          ? DateTime.parse(node['updated_at'] as String)
          : null,
    );
  }

  factory PublicProfileModel.fromMap(
    Map<String, dynamic> map, {
    bool isFollowing = false,
    bool hasRequestedFollow = false,
  }) {
    final isPrivate = map['is_private'] as bool? ?? false;
    final canViewContent = !isPrivate || isFollowing;

    return PublicProfileModel(
      id: map['id'] as String,
      name: map['full_name'] as String?,
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      profileImageUrl: map['avatar_url'] as String?,
      followersCount: _extractCount(map['followers_count']),
      followingCount: _extractCount(map['following_count']),
      answersCount: _extractCount(map['answers_count']),
      isPrivate: isPrivate,
      isFollowing: isFollowing,
      hasRequestedFollow: hasRequestedFollow,
      canViewContent: canViewContent,
      allowAnonymousQuestions:
          map['allow_anonymous_questions'] as bool? ?? true,
      publicProfileEnabled: map['public_profile_enabled'] as bool? ?? true,
      publicThemeKey: map['public_theme_key'] as String? ?? 'tellonym_dark',
      publicCtaText: map['public_cta_text'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
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
