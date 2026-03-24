import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';

class InboxQuestionModel extends InboxQuestion {
  InboxQuestionModel({
    required super.id,
    required super.recipientId,
    super.senderId,
    super.senderUsername,
    super.senderAvatarUrl,
    required super.questionText,
    required super.isAnonymous,
    required super.status,
    required super.createdAt,
  });

  factory InboxQuestionModel.fromMap(Map<String, dynamic> map) {
    // Extract sender details from nested profile data if available
    final senderData = map['sender'] as Map<String, dynamic>?;

    return InboxQuestionModel(
      id: map['id'] as String,
      recipientId: map['recipient_id'] as String,
      senderId: map['sender_id'] as String?,
      senderUsername: senderData?['username'] as String?,
      senderAvatarUrl: senderData?['avatar_url'] as String?,
      questionText: map['question_text'] as String,
      isAnonymous: map['is_anonymous'] as bool? ?? false,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
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
    };
  }
}
