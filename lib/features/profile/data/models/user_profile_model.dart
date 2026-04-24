import 'package:vibi/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.uid,
    required super.name,
    required super.username,
    super.bio,
    super.avatarUrls = const [],
    super.updatedAt,
    required super.followers_count,
    required super.following_count,
    required super.answers_count,
    super.isPrivate,
    super.allowAnonymousQuestions,
    super.publicProfileEnabled,
    super.publicCtaText,
    super.fcmToken,
    super.favColor,
    super.questionPlaceholder,
    super.showSocialIcons,
    super.statusText,
    super.publicFontFamily,
    super.isVerified,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['id'] as String,
      name: map['full_name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      bio: map['bio'] as String?,
      avatarUrls: _parseAvatarUrls(map['avatar_urls']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      followers_count: _extractCount(map['followers_count']),
      following_count: _extractCount(map['following_count']),
      answers_count: _extractCount(map['answers_count']),
      isPrivate: map['is_private'] as bool? ?? false,
      allowAnonymousQuestions:
          map['allow_anonymous_questions'] as bool? ?? true,
      publicProfileEnabled: map['public_profile_enabled'] as bool? ?? true,
      publicCtaText: map['public_cta_text'] as String?,
      fcmToken: map['fcm_token'] as String?,
      favColor: map['fav_color'] as String?,
      questionPlaceholder: map['question_placeholder'] as String?,
      showSocialIcons: map['show_social_icons'] as bool? ?? true,
      statusText: map['status_text'] as String?,
      publicFontFamily: map['public_font_family'] as String? ?? 'inter',
      isVerified: map['is_verified'] as bool? ?? false,
    );
  }

  /// Factory for GraphQL responses
  /// Handles nested GraphQL structure from pg_graphql
  factory UserProfileModel.fromGraphQL(Map<String, dynamic> node) {
    return UserProfileModel(
      uid: node['id'] as String,
      name: node['full_name'] as String,
      username: node['username'] as String,
      bio: node['bio'] as String?,
      avatarUrls: _parseAvatarUrls(node['avatar_urls']),
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
      publicCtaText: node['public_cta_text'] as String?,
      fcmToken: node['fcm_token'] as String?,
      favColor: node['fav_color'] as String?,
      questionPlaceholder: node['question_placeholder'] as String?,
      showSocialIcons: node['show_social_icons'] as bool? ?? true,
      statusText: node['status_text'] as String?,
      publicFontFamily: node['public_font_family'] as String? ?? 'inter',
      isVerified: node['is_verified'] as bool? ?? false,
    );
  }

  static List<String> _parseAvatarUrls(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    // Fallback for single string (backward compatibility if needed, though user said it's changed)
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

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'full_name': name,
      'username': username,
      'bio': bio,
      'avatar_urls': avatarUrls,
      'updated_at': updatedAt?.toIso8601String(),
      'is_private': isPrivate,
      'allow_anonymous_questions': allowAnonymousQuestions,
      'public_profile_enabled': publicProfileEnabled,
      'public_cta_text': publicCtaText,
      'fcm_token': fcmToken,
      'fav_color': favColor,
      'question_placeholder': questionPlaceholder,
      'show_social_icons': showSocialIcons,
      'status_text': statusText,
      'public_font_family': publicFontFamily,
      'is_verified': isVerified,
    };
  }
}
