class InboxQuestion {
  final String id;
  final String recipientId;
  final String? senderId;
  final String? senderUsername;
  final String? senderAvatarUrl;
  final String questionText;
  final bool isAnonymous;
  final String status; // pending, answered, deleted , archive
  final DateTime createdAt;

  InboxQuestion({
    required this.id,
    required this.recipientId,
    this.senderId,
    this.senderUsername,
    this.senderAvatarUrl,
    required this.questionText,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
  });

  bool get isFromUser => !isAnonymous && senderId != null;
}
