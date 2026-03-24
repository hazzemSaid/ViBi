class FeedItem {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String answerAuthorUsername;
  final String? answerAuthorAvatarUrl;
  final String questionText;
  final String answerText;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final bool isAnonymous;

  FeedItem({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.answerAuthorUsername,
    this.answerAuthorAvatarUrl,
    required this.questionText,
    required this.answerText,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.isAnonymous,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
