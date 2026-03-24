class FeedItem {
  final String id;
  final String answerText;
  final String userId;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final String? username;
  final String? avatarUrl;
  final String? answerAuthorUsername;
  final String? answerAuthorAvatarUrl;
  final String? questionText;
  final bool isAnonymous;

  FeedItem({
    required this.id,
    required this.answerText,
    required this.userId,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    this.username,
    this.avatarUrl,
    this.answerAuthorUsername,
    this.answerAuthorAvatarUrl,
    this.questionText,
    this.isAnonymous = false,
  });

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      id: map['id'] as String,
      answerText: map['answer_text'] as String? ?? '',
      userId: map['user_id'] as String,
      likesCount: map['likes_count'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      sharesCount: map['shares_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      questionText: map['question_text'] as String?,
      isAnonymous: map['is_anonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'answer_text': answerText,
      'user_id': userId,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'avatar_url': avatarUrl,
      'question_text': questionText,
      'is_anonymous': isAnonymous,
    };
  }
}
