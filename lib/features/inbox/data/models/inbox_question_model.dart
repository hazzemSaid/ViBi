import 'package:vibi/features/inbox/domain/entities/inbox_question.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class InboxQuestionModel extends InboxQuestion {
  InboxQuestionModel({
    required super.id,
    required super.recipientId,
    super.senderId,
    super.senderUsername,
    super.senderAvatarUrl,
    required super.questionText,
    super.questionType,
    super.mediaRecId,
    super.mediaRec,
    required super.isAnonymous,
    required super.status,
    required super.createdAt,
  });

  factory InboxQuestionModel.fromMap(Map<String, dynamic> map) {
    // Extract sender details from nested profile data if available
    final senderData = map['sender'] as Map<String, dynamic>?;
    final avatarUrls = _parseAvatarUrls(
      senderData?['avatar_urls'] ?? senderData?['avatar_url'],
    );
    final rawQuestionType = (map['question_type'] as String? ?? 'text')
        .trim()
        .toLowerCase();
    final questionType = rawQuestionType.isEmpty ? 'text' : rawQuestionType;
    final mediaRecommendation = _parseMediaRecommendation(
      map['media_recommendations'],
    );
    final questionText = (map['question_text'] as String?)?.trim();

    return InboxQuestionModel(
      id: map['id'] as String,
      recipientId: map['recipient_id'] as String,
      senderId: map['sender_id'] as String?,
      senderUsername: senderData?['username'] as String?,
      senderAvatarUrl: avatarUrls.isNotEmpty ? avatarUrls.first : null,
      questionText: (questionText?.isNotEmpty ?? false)
          ? questionText!
          : (mediaRecommendation?.title ?? ''),
      questionType: questionType,
      mediaRecId: _asInt(map['media_rec_id']),
      mediaRec: mediaRecommendation,
      isAnonymous: map['is_anonymous'] as bool? ?? false,
      status:
          (map['status']?.toString().trim().toLowerCase().isNotEmpty ?? false)
          ? map['status'].toString().trim().toLowerCase()
          : 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  static List<String> _parseAvatarUrls(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) return [value];
    return const [];
  }

  static TmdbMedia? _parseMediaRecommendation(dynamic value) {
    if (value == null) return null;

    Map<String, dynamic>? map;
    if (value is Map<String, dynamic>) {
      map = value;
    } else if (value is Map) {
      map = Map<String, dynamic>.from(value);
    } else if (value is List && value.isNotEmpty && value.first is Map) {
      map = Map<String, dynamic>.from(value.first as Map);
    }

    if (map == null) return null;

    try {
      return TmdbMedia.fromSupabaseMap(map);
    } catch (_) {
      return null;
    }
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'question_text': questionText,
      'question_type': questionType,
      'media_rec_id': mediaRecId,
      'media_recommendations': mediaRec == null
          ? null
          : {
              'tmdb_id': mediaRec!.tmdbId,
              'media_type': mediaRec!.mediaType,
              'title': mediaRec!.title,
              'poster_path': mediaRec!.posterPath,
              'overview': mediaRec!.overview,
              'release_date': mediaRec!.releaseDate,
              'vote_average': mediaRec!.voteAverage,
            },
      'is_anonymous': isAnonymous,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
