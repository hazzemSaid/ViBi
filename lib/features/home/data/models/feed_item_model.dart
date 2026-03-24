import 'package:vibi/features/home/domain/entities/feed_item.dart';

class FeedItemModel extends FeedItem {
  FeedItemModel({
    required super.id,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.answerAuthorUsername,
    super.answerAuthorAvatarUrl,
    required super.questionText,
    required super.answerText,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.createdAt,
    required super.isAnonymous,
  });

  factory FeedItemModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    final question = map['questions'] as Map<String, dynamic>?;

    return FeedItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      username: profile?['username'] as String? ?? 'unknown',
      avatarUrl: profile?['avatar_url'] as String?,
      answerAuthorUsername: 'unknown',
      answerAuthorAvatarUrl: null,
      questionText: question?['question_text'] as String? ?? '',
      answerText: map['answer_text'] as String? ?? '',
      likesCount: map['likes_count'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      sharesCount: map['shares_count'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      isAnonymous: question?['is_anonymous'] as bool? ?? false,
    );
  }

  factory FeedItemModel.fromGraphQL(Map<String, dynamic> node) {
    // Extract answers data (nested structure from global feed query)
    final answersData = node['answers'] as Map<String, dynamic>?;

    // Get answer author's profile
    final answerAuthorProfile =
        answersData?['profiles'] as Map<String, dynamic>?;

    // Questions can be nested in answers or at root level
    final question =
        (answersData?['questions'] as Map<String, dynamic>?) ??
        (node['questions'] as Map<String, dynamic>?);

    // Get questioner's profile (who asked the question)
    // For anonymous questions, this will be null and we'll show "Anonymous User"
    final questionerProfile = question?['profiles'] as Map<String, dynamic>?;

    // Use questioner's profile for display, not the answerer's profile
    final displayName = question?['is_anonymous'] as bool? ?? false
        ? 'Anonymous User'
        : (questionerProfile?['username'] as String? ?? 'unknown');

    final displayAvatar = question?['is_anonymous'] as bool? ?? false
        ? null
        : (questionerProfile?['avatar_url'] as String?);

    return FeedItemModel(
      id: node['id'] as String,
      userId: node['user_id'] as String,
      username: displayName,
      avatarUrl: displayAvatar,
      answerAuthorUsername:
          answerAuthorProfile?['username'] as String? ?? 'unknown',
      answerAuthorAvatarUrl: answerAuthorProfile?['avatar_url'] as String?,
      questionText: question?['question_text'] as String? ?? '',
      answerText:
          answersData?['answer_text'] as String? ??
          node['answer_text'] as String? ??
          '',
      likesCount:
          answersData?['likes_count'] as int? ??
          node['likes_count'] as int? ??
          0,
      commentsCount:
          answersData?['comments_count'] as int? ??
          node['comments_count'] as int? ??
          0,
      sharesCount:
          answersData?['shares_count'] as int? ??
          node['shares_count'] as int? ??
          0,
      createdAt: (answersData?['created_at'] ?? node['created_at']) != null
          ? DateTime.parse(
              (answersData?['created_at'] ?? node['created_at']) as String,
            )
          : DateTime.now(),
      isAnonymous: question?['is_anonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'answer_text': answerText,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
