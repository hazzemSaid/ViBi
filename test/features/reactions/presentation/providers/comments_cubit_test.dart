import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/cubit/comments_cubit.dart';

class _FakeReactionsRepository implements ReactionsRepository {
  _FakeReactionsRepository({
    required ReactionSummary seed,
    Duration? addCommentDelay,
  }) : _summary = seed,
       _addCommentDelay = addCommentDelay ?? Duration.zero;

  ReactionSummary _summary;
  bool throwOnAdd = false;
  final Duration _addCommentDelay;
  final List<CommentItem> _storedComments = [];

  @override
  Future<ReactionSummary> getReactionSummary({
    required String answerId,
    String? userId,
  }) async {
    return _summary;
  }

  @override
  Future<void> toggleReaction({
    required String answerId,
    required String userId,
    required String reaction,
    bool throwOnToggle = false,
  }) async {
    if (throwOnToggle) {
      throw Exception('toggle failed');
    }

    final nextCounts = Map<String, int>.from(_summary.counts);
    final previous = _summary.myReaction;

    if (previous == reaction) {
      nextCounts[reaction] = ((nextCounts[reaction] ?? 0) - 1).clamp(0, 9999);
      _summary = ReactionSummary(counts: nextCounts, myReaction: null);
      return;
    }

    if (previous != null) {
      nextCounts[previous] = ((nextCounts[previous] ?? 0) - 1).clamp(0, 9999);
    }
    nextCounts[reaction] = (nextCounts[reaction] ?? 0) + 1;
    _summary = ReactionSummary(counts: nextCounts, myReaction: reaction);
  }

  @override
  Future<List<CommentItem>> getComments(String answerId) async {
    return _storedComments
        .where((c) => c.answerId == answerId)
        .map((c) => CommentItem(
              id: c.id,
              answerId: c.answerId,
              userId: c.userId,
              body: c.body,
              createdAt: c.createdAt,
              username: c.username,
              isOptimistic: false,
            ))
        .toList();
  }

  @override
  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  }) async {
    if (throwOnAdd) {
      throw Exception('add comment failed');
    }
    await Future.delayed(_addCommentDelay);
    _storedComments.add(
      CommentItem(
        id: 'real-${_storedComments.length + 1}',
        answerId: answerId,
        userId: userId,
        body: body,
        createdAt: DateTime.now(),
        username: 'test-user',
        isOptimistic: false,
      ),
    );
  }

  @override
  Future<int> getCommentsCount(String answerId) async {
    return _storedComments.where((c) => c.answerId == answerId).length;
  }
}

void main() {
  group('CommentsCubit', () {
  test('addComment shows optimistic item then resolves success', () async {
    final repo = _FakeReactionsRepository(
      seed: const ReactionSummary(counts: {'love': 0, 'sad': 0, 'haha': 0}),
      // Add a small delay to simulate network request
      addCommentDelay: const Duration(milliseconds: 10),
    );
    final cubit = CommentsCubit(repo, currentUserIdProvider: () => 'user-1');

    await cubit.load('answer-1');
    expect(cubit.state, isA<CommentsLoaded>());

    final operation = cubit.addComment(answerId: 'answer-1', body: 'hello');
    // Wait briefly to allow optimistic update
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(cubit.state, isA<CommentsLoaded>());
    expect((cubit.state as CommentsLoaded).isSending, isTrue);
    expect(
      (cubit.state as CommentsLoaded).comments.last.isOptimistic,
      isTrue,
    );

    await operation;

    expect((cubit.state as CommentsLoaded).isSending, isFalse);
    expect(cubit.state, isA<CommentsLoaded>());
    expect((cubit.state as CommentsLoaded).comments.last.body, 'hello');
    expect(
      (cubit.state as CommentsLoaded).comments.last.isOptimistic,
      isFalse,
    );

    await cubit.close();
  });

    test('addComment rolls back optimistic item on failure', () async {
      final repo = _FakeReactionsRepository(
        seed: const ReactionSummary(counts: {'love': 3, 'sad': 1, 'haha': 0}),
      );
      final cubit = CommentsCubit(repo, currentUserIdProvider: () => 'user-1');

      await cubit.load('answer-1');
      expect(cubit.state, isA<CommentsLoaded>());

      repo.throwOnAdd = true;
      await cubit.addComment(answerId: 'answer-1', body: 'will fail');

      expect(cubit.state, isA<CommentsFailure>());
      expect((cubit.state as CommentsFailure).comments, isEmpty);

      await cubit.close();
    });
  });
}
