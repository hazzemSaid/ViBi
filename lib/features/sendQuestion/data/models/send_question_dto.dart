class SendQuestionDto {
  final String recipientId;
  final String questionText;
  final bool isAnonymous;
  final String? senderId;

  const SendQuestionDto({
    required this.recipientId,
    required this.questionText,
    required this.isAnonymous,
    this.senderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipient_id': recipientId,
      'sender_id': isAnonymous ? null : senderId,
      'question_text': questionText,
      'is_anonymous': isAnonymous,
      'status': 'pending',
    };
  }
}
