import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/providers/comments_state.dart';

export 'package:vibi/features/reactions/presentation/providers/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository, {String? Function()? currentUserIdProvider})
    : _currentUserIdProvider =
          currentUserIdProvider ??
          (() => Supabase.instance.client.auth.currentUser?.id),
      super(const CommentsInitial());

  final ReactionsRepository _repository;
  final String? Function() _currentUserIdProvider;

  Future<void> load(String answerId) async {
    try {
      emit(CommentsLoading(comments: state.comments, isSending: state.isSending));

      final comments = await _repository.getComments(answerId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      debugPrint('[CommentsCubit] load failed for answerId=$answerId: $e');
      emit(CommentsFailure('$e', comments: state.comments));
    }
  }

  Future<void> addComment({
    required String answerId,
    required String body,
  }) async {
    final userId = _currentUserIdProvider();
    if (userId == null) {
      debugPrint('[CommentsCubit] addComment skipped: userId is null');
      return;
    }

    final text = body.trim();
    if (text.isEmpty) {
      debugPrint('[CommentsCubit] addComment skipped: empty body');
      return;
    }

    final currentComments = state.comments;
    final optimistic = CommentItem(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      answerId: answerId,
      userId: userId,
      body: text,
      createdAt: DateTime.now(),
      username: 'You',
      isOptimistic: true,
    );

    emit(
      CommentsLoaded(
        comments: [...currentComments, optimistic],
        isSending: true,
      ),
    );

    if (kDebugMode) {
      debugPrint(
        '[CommentsCubit][optimistic] answerId=$answerId, optimisticCount=${currentComments.length + 1}',
      );
    }

    try {
      await _repository.addComment(
        answerId: answerId,
        userId: userId,
        body: text,
      );

      final fresh = await _repository.getComments(answerId);
      emit(CommentsLoaded(comments: fresh, isSending: false));
      debugPrint(
        '[CommentsCubit][confirmed] answerId=$answerId, count=${fresh.length}',
      );
    } catch (e) {
      debugPrint('[CommentsCubit][rollback] answerId=$answerId: $e');
      emit(
        CommentsFailure(
          '$e',
          comments: currentComments,
          isSending: false,
        ),
      );
    }
  }
}
