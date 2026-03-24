import 'package:vibi/features/profile/domain/entities/answered_question.dart';

class AnsweredQuestionModel extends AnsweredQuestion {
  AnsweredQuestionModel({
    required super.id,
    required super.userId,
    required super.questionText,
    required super.answerText,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.createdAt,
    required super.isAnonymous,
    super.senderUsername,
    super.senderAvatarUrl,
    super.answererUsername,
    super.answererAvatarUrl,
  });

  factory AnsweredQuestionModel.fromMap(Map<String, dynamic> map) {
    final question = map['questions'] as Map<String, dynamic>?;

    return AnsweredQuestionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
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
}
