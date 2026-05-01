import 'package:equatable/equatable.dart';

class AnsweredQuestion extends Equatable {
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

  AnsweredQuestion copyWith({
    String? id,
    String? userId,
    String? questionText,
    String? answerText,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    bool? isAnonymous,
    String? senderUsername,
    String? senderAvatarUrl,
    String? answererUsername,
    String? answererAvatarUrl,
  }) {
    return AnsweredQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      answererUsername: answererUsername ?? this.answererUsername,
      answererAvatarUrl: answererAvatarUrl ?? this.answererAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnsweredQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}
