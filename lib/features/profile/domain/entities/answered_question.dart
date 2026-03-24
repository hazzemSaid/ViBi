class AnsweredQuestion {
  final String id;
  final String userId;
  final String questionText;
  final String answerText;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final bool isAnonymous;
  final String? senderUsername;
  final String? senderAvatarUrl;
  final String? answererUsername;
  final String? answererAvatarUrl;

  AnsweredQuestion({
    required this.id,
    required this.userId,
    required this.questionText,
    required this.answerText,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.isAnonymous,
    this.senderUsername,
    this.senderAvatarUrl,
    this.answererUsername,
    this.answererAvatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnsweredQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
