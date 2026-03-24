class PublicProfile {
  final String id;
  final String? name;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final int followersCount;
  final int followingCount;
  final int answersCount;
  final bool isPrivate;
  final bool isFollowing;
  final bool hasRequestedFollow;
  final bool canViewContent;
  final bool allowAnonymousQuestions;
  final bool publicProfileEnabled;
  final String publicThemeKey;
  final String? publicCtaText;
  final DateTime? updatedAt;

  PublicProfile({
    required this.id,
    this.name,
    this.username,
    this.bio,
    this.profileImageUrl,
    required this.followersCount,
    required this.followingCount,
    required this.answersCount,
    required this.isPrivate,
    required this.isFollowing,
    required this.hasRequestedFollow,
    required this.canViewContent,
    this.allowAnonymousQuestions = true,
    this.publicProfileEnabled = true,
    this.publicThemeKey = 'tellonym_dark',
    this.publicCtaText,
    this.updatedAt,
  });

  PublicProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
    int? followersCount,
    int? followingCount,
    int? answersCount,
    bool? isPrivate,
    bool? isFollowing,
    bool? hasRequestedFollow,
    bool? canViewContent,
    bool? allowAnonymousQuestions,
    bool? publicProfileEnabled,
    String? publicThemeKey,
    String? publicCtaText,
    DateTime? updatedAt,
  }) {
    return PublicProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      answersCount: answersCount ?? this.answersCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isFollowing: isFollowing ?? this.isFollowing,
      hasRequestedFollow: hasRequestedFollow ?? this.hasRequestedFollow,
      canViewContent: canViewContent ?? this.canViewContent,
      allowAnonymousQuestions:
          allowAnonymousQuestions ?? this.allowAnonymousQuestions,
      publicProfileEnabled: publicProfileEnabled ?? this.publicProfileEnabled,
      publicThemeKey: publicThemeKey ?? this.publicThemeKey,
      publicCtaText: publicCtaText ?? this.publicCtaText,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
