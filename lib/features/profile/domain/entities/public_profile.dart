class PublicProfile {
  final String id;
  final String? name;
  final String? username;
  final String? bio;
  final List<String> avatarUrls;
  final int followersCount;
  final int followingCount;
  final int answersCount;
  final bool isPrivate;
  final bool isFollowing;
  final bool hasRequestedFollow;
  final bool canViewContent;
  final bool allowAnonymousQuestions;
  final bool publicProfileEnabled;
  final String? publicCtaText;
  final DateTime? updatedAt;
  final String? favColor;
  final String? questionPlaceholder;
  final bool showSocialIcons;
  final String? statusText;
  final String publicFontFamily;
  final bool isVerified;
  final String? backgroundcolor;

  PublicProfile({
    required this.id,
    this.name,
    this.username,
    this.bio,
    this.avatarUrls = const [],
    required this.followersCount,
    required this.followingCount,
    required this.answersCount,
    required this.isPrivate,
    required this.isFollowing,
    required this.hasRequestedFollow,
    required this.canViewContent,
    this.allowAnonymousQuestions = true,
    this.publicProfileEnabled = true,
    this.publicCtaText,
    this.updatedAt,
    this.favColor,
    this.questionPlaceholder,
    this.showSocialIcons = true,
    this.statusText,
    this.publicFontFamily = 'inter',
    this.isVerified = false,
    this.backgroundcolor,
  });

  PublicProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    List<String>? avatarUrls,
    int? followersCount,
    int? followingCount,
    int? answersCount,
    bool? isPrivate,
    bool? isFollowing,
    bool? hasRequestedFollow,
    bool? canViewContent,
    bool? allowAnonymousQuestions,
    bool? publicProfileEnabled,
    String? publicCtaText,
    DateTime? updatedAt,
    String? favColor,
    String? questionPlaceholder,
    bool? showSocialIcons,
    String? statusText,
    String? publicFontFamily,
    bool? isVerified,
    String? backgroundcolor,
  }) {
    return PublicProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrls: avatarUrls ?? this.avatarUrls,
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
      publicCtaText: publicCtaText ?? this.publicCtaText,
      showSocialIcons: showSocialIcons ?? this.showSocialIcons,
      statusText: statusText ?? this.statusText,
      publicFontFamily: publicFontFamily ?? this.publicFontFamily,
      isVerified: isVerified ?? this.isVerified,
      backgroundcolor: backgroundcolor ?? this.backgroundcolor,
    );
  }
}
