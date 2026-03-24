class UserProfile {
  final String uid;
  final String? name;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final DateTime? updatedAt;
  final int? followers_count;
  final int? following_count;
  final int? answers_count;
  final bool isPrivate;
  final bool allowAnonymousQuestions;
  final bool publicProfileEnabled;
  final String publicThemeKey;
  final String? publicCtaText;
  final String? fcmToken;
  UserProfile({
    required this.uid,
    this.name,
    this.username,
    this.bio,
    this.profileImageUrl,
    this.updatedAt,
    this.followers_count,
    this.following_count,
    this.answers_count,
    this.isPrivate = false,
    this.allowAnonymousQuestions = true,
    this.publicProfileEnabled = true,
    this.publicThemeKey = 'tellonym_dark',
    this.publicCtaText,
    this.fcmToken,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
    DateTime? updatedAt,
    int? followers_count,
    int? following_count,
    int? answers_count,
    bool? isPrivate,
    bool? allowAnonymousQuestions,
    bool? publicProfileEnabled,
    String? publicThemeKey,
    String? publicCtaText,
    String? fcmToken,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      followers_count: followers_count ?? this.followers_count,
      following_count: following_count ?? this.following_count,
      answers_count: answers_count ?? this.answers_count,
      isPrivate: isPrivate ?? this.isPrivate,
      allowAnonymousQuestions:
          allowAnonymousQuestions ?? this.allowAnonymousQuestions,
      publicProfileEnabled: publicProfileEnabled ?? this.publicProfileEnabled,
      publicThemeKey: publicThemeKey ?? this.publicThemeKey,
      publicCtaText: publicCtaText ?? this.publicCtaText,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
