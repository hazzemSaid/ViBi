import 'package:vibi/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.uid,
    super.name,
    super.username,
    super.bio,
    super.profileImageUrl,
    super.updatedAt,
    super.followers_count,
    super.following_count,
    super.answers_count,
    super.isPrivate,
    super.allowAnonymousQuestions,
    super.publicProfileEnabled,
    super.publicThemeKey,
    super.publicCtaText,
    super.fcmToken,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['id'] as String,
      name: map['full_name'] as String?,
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      profileImageUrl: map['avatar_url'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      followers_count: map['followers_count'],
      following_count: map['following_count'],
      answers_count: map['answers_count'],
      isPrivate: map['is_private'] as bool? ?? false,
      allowAnonymousQuestions:
          map['allow_anonymous_questions'] as bool? ?? true,
      publicProfileEnabled: map['public_profile_enabled'] as bool? ?? true,
      publicThemeKey: map['public_theme_key'] as String? ?? 'tellonym_dark',
      publicCtaText: map['public_cta_text'] as String?,
      fcmToken: map['fcm_token'] as String?,
    );
  }

  /// Factory for GraphQL responses
  /// Handles nested GraphQL structure from pg_graphql
  factory UserProfileModel.fromGraphQL(Map<String, dynamic> node) {
    return UserProfileModel(
      uid: node['id'] as String,
      name: node['full_name'] as String?,
      username: node['username'] as String?,
      bio: node['bio'] as String?,
      profileImageUrl: node['avatar_url'] as String?,
      updatedAt: node['updated_at'] != null
          ? DateTime.parse(node['updated_at'] as String)
          : null,
      followers_count: _extractCount(
        node['followersCount'],
        fallback: node['followers_count'],
      ),
      following_count: _extractCount(
        node['followingCount'],
        fallback: node['following_count'],
      ),
      answers_count: _extractCount(
        node['answersCount'],
        fallback: node['answers_count'],
      ),
      isPrivate: node['is_private'] as bool? ?? false,
      allowAnonymousQuestions:
          node['allow_anonymous_questions'] as bool? ?? true,
      publicProfileEnabled: node['public_profile_enabled'] as bool? ?? true,
      publicThemeKey: node['public_theme_key'] as String? ?? 'tellonym_dark',
      publicCtaText: node['public_cta_text'] as String?,
      fcmToken: node['fcm_token'] as String?,
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

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'full_name': name,
      'username': username,
      'bio': bio,
      'avatar_url': profileImageUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'followers_count': followers_count,
      'following_count': following_count,
      'answers_count': answers_count,
      'is_private': isPrivate,
      'allow_anonymous_questions': allowAnonymousQuestions,
      'public_profile_enabled': publicProfileEnabled,
      'public_theme_key': publicThemeKey,
      'public_cta_text': publicCtaText,
      'fcm_token': fcmToken,
    };
  }
}
