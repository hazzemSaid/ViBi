class ContentSearchResult {
  final String id;
  final String userId;
  final String? username;
  final String? avatarUrl;
  final String questionText;
  final String answerText;
  final int likesCount;
  final DateTime createdAt;
  final bool isAnonymous;

  ContentSearchResult({
    required this.id,
    required this.userId,
    this.username,
    this.avatarUrl,
    required this.questionText,
    required this.answerText,
    required this.likesCount,
    required this.createdAt,
    required this.isAnonymous,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
