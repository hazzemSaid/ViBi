import 'package:vibi/features/feed/domain/entities/feed_item.dart';

class FeedItemModel extends FeedItem {
  FeedItemModel({
    required super.id,
    required super.answerText,
    required super.userId,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.createdAt,
    super.username,
    super.avatarUrl,
    super.answerAuthorUsername,
    super.answerAuthorAvatarUrl,
    super.questionText,
    super.isAnonymous,
  });

  factory FeedItemModel.fromMap(Map<String, dynamic> map) {
    final avatarUrls = _parseAvatarUrls(map['avatar_urls'] ?? map['avatar_url']);
    final authorAvatarUrls = _parseAvatarUrls(map['answer_author_avatar_urls'] ?? map['answer_author_avatar_url']);

    return FeedItemModel(
      id: map['id'] as String,
      answerText: map['answer_text'] as String? ?? '',
      userId: map['user_id'] as String,
      likesCount: map['likes_count'] as int? ?? 0,
      commentsCount: map['comments_count'] as int? ?? 0,
      sharesCount: map['shares_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      username: map['username'] as String?,
      avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
      answerAuthorUsername: map['answer_author_username'] as String?,
      answerAuthorAvatarUrl: authorAvatarUrls.isNotEmpty ? authorAvatarUrls.first : null,
      questionText: map['question_text'] as String?,
      isAnonymous: map['is_anonymous'] as bool? ?? false,
    );
  }

  factory FeedItemModel.fromGraphQL(Map<String, dynamic> node) {
    // Handle both nested (answers-based) and flat (answers-direct) GraphQL responses
    final answersData = node['answers'] as Map<String, dynamic>?;

    // Get answer author's profile
    final answerAuthorProfile =
        answersData?['profiles'] as Map<String, dynamic>?;

    // Questions can be at root level or nested in answers
    final question =
        (node['questions'] as Map<String, dynamic>?) ??
        (answersData?['questions'] as Map<String, dynamic>?) ??
        {};

    // Get questioner's profile (who asked the question)
    final questionerProfile =
        question['profiles'] as Map<String, dynamic>? ?? {};

    // Answer data can come from root level or from nested answers object
    final answerText =
      (node['answer_text'] as String?) ??
      (answersData?['answer_text'] as String?) ??
      '';
    final likesCount =
      (node['likes_count'] as int?) ??
      (answersData?['likes_count'] as int?) ??
      0;
    final commentsCount =
      (node['comments_count'] as int?) ??
      (answersData?['comments_count'] as int?) ??
      0;
    final sharesCount =
      (node['shares_count'] as int?) ??
      (answersData?['shares_count'] as int?) ??
      0;

    // Use questioner's profile, handle anonymous questions
    final isAnon = question['is_anonymous'] as bool? ?? false;
    final displayName = isAnon
        ? 'Anonymous User'
        : (questionerProfile['username'] as String?);
    
    final questionerAvatarUrls = _parseAvatarUrls(questionerProfile['avatar_urls']);
    final displayAvatar = isAnon
        ? null
        : (questionerAvatarUrls.isNotEmpty ? questionerAvatarUrls.first : null);

    final authorAvatarUrls = _parseAvatarUrls(answerAuthorProfile?['avatar_urls']);

    return FeedItemModel(
      id: node['id'] as String,
      answerText: answerText,
      userId: node['user_id'] as String,
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      createdAt: DateTime.parse(node['created_at'] as String),
      username: displayName,
      avatarUrl: displayAvatar,
      answerAuthorUsername: answerAuthorProfile?['username'] as String?,
      answerAuthorAvatarUrl: authorAvatarUrls.isNotEmpty ? authorAvatarUrls.first : null,
      questionText: question['question_text'] as String?,
      isAnonymous: isAnon,
    );
  }

  static List<String> _parseAvatarUrls(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) return [value];
    return const [];
  }

  @override
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
      'avatar_urls': avatarUrl != null ? [avatarUrl!] : [],
      'question_text': questionText,
      'is_anonymous': isAnonymous,
    };
  }
}
