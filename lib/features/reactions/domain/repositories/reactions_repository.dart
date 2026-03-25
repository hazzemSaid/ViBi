import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';

abstract class ReactionsRepository {
  Future<ReactionSummary> getReactionSummary({
    required String answerId,
    String? userId,
  });

  Future<void> toggleReaction({
    required String answerId,
    required String userId,
    required String reaction,
  });

  Future<List<CommentItem>> getComments(String answerId);

  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  });

  Future<int> getCommentsCount(String answerId);
}
