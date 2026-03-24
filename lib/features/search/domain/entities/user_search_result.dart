class UserSearchResult {
  final String id;
  final String? name;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final int followersCount;
  final int answersCount;
  final bool isPrivate;

  UserSearchResult({
    required this.id,
    this.name,
    this.username,
    this.bio,
    this.profileImageUrl,
    required this.followersCount,
    required this.answersCount,
    required this.isPrivate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
