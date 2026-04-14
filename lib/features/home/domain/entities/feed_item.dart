import 'package:equatable/equatable.dart';

class FeedItem extends Equatable {
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

  const FeedItem({
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

  FeedItem copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? answerAuthorUsername,
    String? answerAuthorAvatarUrl,
    String? questionText,
    String? answerText,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return FeedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      answerAuthorUsername: answerAuthorUsername ?? this.answerAuthorUsername,
      answerAuthorAvatarUrl:
          answerAuthorAvatarUrl ?? this.answerAuthorAvatarUrl,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    avatarUrl,
    answerAuthorUsername,
    answerAuthorAvatarUrl,
    questionText,
    answerText,
    likesCount,
    commentsCount,
    sharesCount,
    createdAt,
    isAnonymous,
  ];
}
