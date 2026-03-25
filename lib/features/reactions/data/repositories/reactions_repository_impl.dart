import 'package:vibi/features/reactions/data/datasources/reactions_remote_data_source.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';

class ReactionsRepositoryImpl implements ReactionsRepository {
  ReactionsRepositoryImpl(this._remote);

  final ReactionsRemoteDataSource _remote;

  @override
  Future<ReactionSummary> getReactionSummary({
    required String answerId,
    String? userId,
  }) async {
    final counts = await _remote.getReactionCounts(answerId);
    String? mine;
    if (userId != null) {
      mine = await _remote.getMyReaction(answerId: answerId, userId: userId);
    }

    return ReactionSummary(counts: counts, myReaction: mine);
  }

  @override
  Future<void> toggleReaction({
    required String answerId,
    required String userId,
    required String reaction,
  }) {
    return _remote.toggleReaction(
      answerId: answerId,
      userId: userId,
      reaction: reaction,
    );
  }

  @override
  Future<List<CommentItem>> getComments(String answerId) async {
    final rows = await _remote.getComments(answerId);
    return rows.map(_mapComment).toList();
  }

  @override
  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  }) {
    return _remote.addComment(answerId: answerId, userId: userId, body: body);
  }

  @override
  Future<int> getCommentsCount(String answerId) {
    return _remote.getCommentsCount(answerId);
  }

  CommentItem _mapComment(Map<String, dynamic> row) {
    final profile = row['profiles'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : (profile is List &&
              profile.isNotEmpty &&
              profile.first is Map<String, dynamic>)
        ? profile.first as Map<String, dynamic>
        : <String, dynamic>{};

    return CommentItem(
      id: row['id'] as String,
      answerId: row['answer_id'] as String,
      userId: row['user_id'] as String,
      body: row['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      username: profileMap['username'] as String?,
      avatarUrl: profileMap['avatar_url'] as String?,
    );
  }
}
