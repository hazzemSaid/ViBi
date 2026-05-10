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
  final String questionType;
  final String? drawingUrl;

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
    this.questionType = 'text',
    this.drawingUrl,
  });

  bool get isDrawing => questionType == 'drawing' && drawingUrl != null;

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
    String? questionType,
    String? drawingUrl,
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
      questionType: questionType ?? this.questionType,
      drawingUrl: drawingUrl ?? this.drawingUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    questionText,
    answerText,
    likesCount,
    commentsCount,
    sharesCount,
    createdAt,
    isAnonymous,
    senderUsername,
    senderAvatarUrl,
    answererUsername,
    answererAvatarUrl,
    questionType,
    drawingUrl,
  ];
}
