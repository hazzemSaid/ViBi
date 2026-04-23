import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class InboxQuestion {
  final String id;
  final String recipientId;
  final String? senderId;
  final String? senderUsername;
  final String? senderAvatarUrl;
  final String questionText;
  final String questionType;
  final int? mediaRecId;
  final TmdbMedia? mediaRec;
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
    this.questionType = 'text',
    this.mediaRecId,
    this.mediaRec,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
  });

  bool get isFromUser => !isAnonymous && senderId != null;
  bool get isRecommendation => questionType == 'recommendation';
}
