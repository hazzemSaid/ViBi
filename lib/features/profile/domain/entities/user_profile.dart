class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String? bio;
  final List<String> avatarUrls;
  final DateTime? updatedAt;
  final int followers_count;
  final int following_count;
  final int answers_count;
  final bool isPrivate;
  final bool allowAnonymousQuestions;
  final bool publicProfileEnabled;
  final String publicThemeKey;
  final String? publicCtaText;
  final String? fcmToken;
  final String linkButtonStyle;
  final String? favColor;
  final String? questionPlaceholder;
  final bool showSocialIcons;
  final String? statusText;
  final String publicFontFamily;
  final bool isVerified;
  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    this.bio,
    this.avatarUrls = const [],
    this.updatedAt,
    required this.followers_count,
    required this.following_count,
    required this.answers_count,
    this.isPrivate = false,
    this.allowAnonymousQuestions = true,
    this.publicProfileEnabled = true,
    this.publicThemeKey = 'tellonym_dark',
    this.publicCtaText,
    this.fcmToken,
    this.linkButtonStyle = 'pill',
    this.favColor,
    this.questionPlaceholder,
    this.showSocialIcons = true,
    this.statusText,
    this.publicFontFamily = 'inter',
    this.isVerified = false,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? username,
    String? bio,
    List<String>? avatarUrls,
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
    String? linkButtonStyle,
    String? favColor,
    String? questionPlaceholder,
    bool? showSocialIcons,
    String? statusText,
    String? publicFontFamily,
    bool? isVerified,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrls: avatarUrls ?? this.avatarUrls,
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
      linkButtonStyle: linkButtonStyle ?? this.linkButtonStyle,
      favColor: favColor ?? this.favColor,
      questionPlaceholder: questionPlaceholder ?? this.questionPlaceholder,
      showSocialIcons: showSocialIcons ?? this.showSocialIcons,
      statusText: statusText ?? this.statusText,
      publicFontFamily: publicFontFamily ?? this.publicFontFamily,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
