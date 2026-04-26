import 'package:flutter_test/flutter_test.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/providers/reaction_cubit.dart';
import 'package:vibi/features/reactions/presentation/providers/reaction_state.dart';

class _FakeReactionsRepository implements ReactionsRepository {
  _FakeReactionsRepository({required ReactionSummary seed}) : _summary = seed;

  ReactionSummary _summary;
  bool throwOnToggle = false;

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
  Future<List<CommentItem>> getComments(String answerId) async => const [];

  @override
  Future<void> addComment({
    required String answerId,
    required String userId,
    required String body,
  }) async {}

  @override
  Future<int> getCommentsCount(String answerId) async => 0;
}

void main() {
  group('ReactionCubit', () {
    test(
      'toggleReaction applies optimistic flow and ends in success',
      () async {
        final repo = _FakeReactionsRepository(
          seed: const ReactionSummary(counts: {'love': 1, 'sad': 0, 'haha': 0}),
        );
        final cubit = ReactionCubit(
          repo,
          currentUserIdProvider: () => 'user-1',
        );

        await cubit.load('answer-1');
        await cubit.toggleReaction(answerId: 'answer-1', reaction: 'love');

        expect(cubit.state, isA<ReactionLoaded>());
        expect((cubit.state as ReactionLoaded).summary.myReaction, 'love');
        expect((cubit.state as ReactionLoaded).summary.counts['love'], 2);

        await cubit.close();
      },
    );

    test(
      'toggleReaction rolls back and emits failure when repository fails',
      () async {
        final repo = _FakeReactionsRepository(
          seed: const ReactionSummary(counts: {'love': 3, 'sad': 1, 'haha': 0}),
        );
        repo.throwOnToggle = true;
        final cubit = ReactionCubit(
          repo,
          currentUserIdProvider: () => 'user-1',
        );

        await cubit.load('answer-1');
        await cubit.toggleReaction(answerId: 'answer-1', reaction: 'sad');

        expect(cubit.state, isA<ReactionFailure>());
        expect(
          (cubit.state as ReactionFailure).fallbackSummary?.counts['love'],
          3,
        );
        expect(
          (cubit.state as ReactionFailure).fallbackSummary?.counts['sad'],
          1,
        );
        expect(
          (cubit.state as ReactionFailure).fallbackSummary?.myReaction,
          isNull,
        );

        await cubit.close();
      },
    );
  });
}
