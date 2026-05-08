import 'package:equatable/equatable.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';
import 'package:vibi/features/recommendation/data/models/tmdb_media.dart';

class PostBodyData extends Equatable {
  const PostBodyData({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.answerAuthorUsername,
    required this.answerAuthorAvatarUrl,
    required this.questionText,
    required this.questionType,
    required this.mediaRec,
    required this.answerText,
    required this.isAnonymous,
    this.drawingUrl,
  });

  factory PostBodyData.fromFeedItem(FeedItem item) {
    return PostBodyData(
      id: item.id,
      username: item.username,
      avatarUrl: item.avatarUrl,
      answerAuthorUsername: item.answerAuthorUsername,
      answerAuthorAvatarUrl: item.answerAuthorAvatarUrl,
      questionText: item.questionText,
      questionType: item.questionType,
      mediaRec: item.mediaRec,
      answerText: item.answerText,
      isAnonymous: item.isAnonymous,
      drawingUrl: item.drawingUrl,
    );
  }

  final String id;
  final String username;
  final String? avatarUrl;
  final String answerAuthorUsername;
  final String? answerAuthorAvatarUrl;
  final String questionText;
  final String questionType;
  final TmdbMedia? mediaRec;
  final String answerText;
  final bool isAnonymous;
  final String? drawingUrl;

  String get displayName => isAnonymous ? 'Anonymous' : username;
  String? get displayAvatar => isAnonymous ? null : avatarUrl;

  @override
  List<Object?> get props => [
    id,
    username,
    avatarUrl,
    answerAuthorUsername,
    answerAuthorAvatarUrl,
    questionText,
    questionType,
    mediaRec,
    answerText,
    isAnonymous,
    drawingUrl,
  ];
}
