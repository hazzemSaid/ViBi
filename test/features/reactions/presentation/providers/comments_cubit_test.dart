import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/providers/comments_cubit.dart';

class _FakeReactionsRepository implements ReactionsRepository {
  _FakeReactionsRepository({List<CommentItem>? seed})
    : _comments = List<CommentItem>.from(seed ?? const []);

  final List<CommentItem> _comments;
  bool throwOnAdd = false;
  Completer<void>? addBlocker;

  @override
  Future<ReactionSummary> getReactionSummary({
    required String answerId,
    String? userId,
  }) async {
    return const ReactionSummary(counts: {'love': 0, 'sad': 0, 'haha': 0});
  }

  @override
  Future<void> toggleReaction({
    required String answerId,
    required String userId,
    required String reaction,
  }) async {}

  @override
  Future<List<CommentItem>> getComments(String answerId) async {
    return List<CommentItem>.from(_comments);
  }

  @override
  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  }) async {
    if (addBlocker != null) {
      await addBlocker!.future;
    }

    if (throwOnAdd) {
      throw Exception('add failed');
    }

    _comments.add(
      CommentItem(
        id: 'c-${_comments.length + 1}',
        answerId: answerId,
        userId: userId,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<int> getCommentsCount(String answerId) async => _comments.length;
}

void main() {
  group('CommentsCubit', () {
    test('addComment shows optimistic item then resolves success', () async {
      final repo = _FakeReactionsRepository();
      repo.addBlocker = Completer<void>();
      final cubit = CommentsCubit(repo, currentUserIdProvider: () => 'user-1');

      await cubit.load('answer-1');

      final operation = cubit.addComment(answerId: 'answer-1', body: 'hello');
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(cubit.state.isSending, isTrue);
      expect(cubit.state.viewState.status, ViewStatus.success);
      expect(cubit.state.viewState.data?.last.isOptimistic, isTrue);

      repo.addBlocker!.complete();
      await operation;

      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.viewState.status, ViewStatus.success);
      expect(cubit.state.viewState.data?.last.body, 'hello');
      expect(cubit.state.viewState.data?.last.isOptimistic, isFalse);

      await cubit.close();
    });

    test('addComment rolls back optimistic item on failure', () async {
      final repo = _FakeReactionsRepository();
      repo.throwOnAdd = true;
      final cubit = CommentsCubit(repo, currentUserIdProvider: () => 'user-1');

      await cubit.load('answer-1');
      await cubit.addComment(answerId: 'answer-1', body: 'will fail');

      expect(cubit.state.isSending, isFalse);
      expect(cubit.state.viewState.status, ViewStatus.failure);
      expect(cubit.state.viewState.data, isEmpty);

      await cubit.close();
    });
  });
}
