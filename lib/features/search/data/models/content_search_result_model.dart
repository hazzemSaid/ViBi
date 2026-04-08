import 'package:vibi/features/search/domain/entities/content_search_result.dart';

class ContentSearchResultModel extends ContentSearchResult {
  ContentSearchResultModel({
    required super.id,
    required super.userId,
    super.username,
    super.avatarUrl,
    required super.questionText,
    required super.answerText,
    required super.likesCount,
    required super.createdAt,
    required super.isAnonymous,
  });

  factory ContentSearchResultModel.fromGraphQL(Map<String, dynamic> node) {
    final question = node['questions'] as Map<String, dynamic>?;
    final profile = node['profiles'] as Map<String, dynamic>?;
    final avatarUrls = _parseAvatarUrls(profile?['avatar_urls']);

    return ContentSearchResultModel(
      id: node['id'] as String,
      userId: node['user_id'] as String,
      username: profile?['username'] as String?,
      avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
      questionText: question?['question_text'] as String? ?? '',
      answerText: node['answer_text'] as String? ?? '',
      likesCount: node['likes_count'] as int? ?? 0,
      createdAt: node['created_at'] != null
          ? DateTime.parse(node['created_at'] as String)
          : DateTime.now(),
      isAnonymous: question?['is_anonymous'] as bool? ?? false,
    );
  }

  factory ContentSearchResultModel.fromMap(Map<String, dynamic> map) {
    final question = map['questions'] as Map<String, dynamic>?;
    final profile = map['profiles'] as Map<String, dynamic>?;
    final avatarUrls = _parseAvatarUrls(
      profile?['avatar_urls'] ?? profile?['avatar_url'],
    );

    return ContentSearchResultModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      username: profile?['username'] as String?,
      avatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
      questionText: question?['question_text'] as String? ?? '',
      answerText: map['answer_text'] as String? ?? '',
      likesCount: map['likes_count'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      isAnonymous: question?['is_anonymous'] as bool? ?? false,
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
}
