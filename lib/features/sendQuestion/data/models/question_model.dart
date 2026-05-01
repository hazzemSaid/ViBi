import 'package:vibi/features/sendQuestion/domain/entities/question.dart';

class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.recipientId,
    super.senderId,
    required super.questionText,
    required super.isAnonymous,
    required super.status,
    required super.createdAt,
    super.answeredAt,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as String,
      recipientId: map['recipient_id'] as String,
      senderId: map['sender_id'] as String?,
      questionText: map['question_text'] as String,
      isAnonymous: map['is_anonymous'] as bool? ?? false,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      answeredAt: map['answered_at'] != null
          ? DateTime.parse(map['answered_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'question_text': questionText,
      'is_anonymous': isAnonymous,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
    };
  }
}
