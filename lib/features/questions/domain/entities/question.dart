class Question {
  final String id;
  final String recipientId;
  final String? senderId;
  final String questionText;
  final bool isAnonymous;
  final String status; // pending, answered, deleted
  final DateTime createdAt;
  final DateTime? answeredAt;

  Question({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.questionText,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
    this.answeredAt,
  });
}
