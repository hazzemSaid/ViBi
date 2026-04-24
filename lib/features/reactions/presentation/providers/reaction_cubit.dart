import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';
import 'package:vibi/features/reactions/presentation/providers/reaction_state.dart';

class ReactionCubit extends Cubit<ReactionState> {
  ReactionCubit(this._repository, {String? Function()? currentUserIdProvider})
    : _currentUserIdProvider =
          currentUserIdProvider ??
          (() => Supabase.instance.client.auth.currentUser?.id),
      super(const ReactionInitial());

  final ReactionsRepository _repository;
  final String? Function() _currentUserIdProvider;
  bool _isToggling = false;

  Future<void> load(String answerId) async {
    try {
      emit(const ReactionLoading());
      final userId = _currentUserIdProvider();
      final summary = await _repository.getReactionSummary(
        answerId: answerId,
        userId: userId,
      );
      if (isClosed) return;
      emit(ReactionLoaded(summary));
    } catch (e) {
      debugPrint('[ReactionCubit] load failed for answerId=$answerId: $e');
      if (isClosed) return;
      emit(ReactionFailure('$e'));
    }
  }

  Future<void> toggleReaction({
    required String answerId,
    required String reaction,
  }) async {
    if (_isToggling) {
      debugPrint('[ReactionCubit] ignoring toggle: already in flight');
      return;
    }

    final userId = _currentUserIdProvider();
    if (userId == null) return;

    _isToggling = true;

    final currentState = state;
    ReactionSummary? currentSummary = (currentState is ReactionLoaded) ? currentState.summary : null;
    
    if (currentSummary == null) {
      debugPrint(
        '[ReactionCubit] currentState is not Loaded on toggle; state=$currentState. Fetching summary first.',
      );
      try {
        currentSummary = await _repository.getReactionSummary(
          answerId: answerId,
          userId: userId,
        );
        if (isClosed) return;
        emit(ReactionLoaded(currentSummary));
      } catch (e) {
        debugPrint('[ReactionCubit] pre-toggle summary fetch failed: $e');
        if (!isClosed) {
          emit(ReactionFailure('$e'));
        }
        _isToggling = false;
        return;
      }
    }

    final previousCounts = Map<String, int>.from(currentSummary.counts);
    final nextCounts = Map<String, int>.from(previousCounts);
    final previousReaction = currentSummary.myReaction;

    String? nextMyReaction;
    if (previousReaction == reaction) {
      nextCounts[reaction] = ((nextCounts[reaction] ?? 0) - 1).clamp(0, 9999);
      nextMyReaction = null;
    } else {
      if (previousReaction != null) {
        nextCounts[previousReaction] = ((nextCounts[previousReaction] ?? 0) - 1)
            .clamp(0, 9999);
      }
      nextCounts[reaction] = (nextCounts[reaction] ?? 0) + 1;
      nextMyReaction = reaction;
    }
    if (kDebugMode) {
      debugPrint(
        '[ReactionCubit][optimistic] answerId=$answerId: $previousReaction -> $nextMyReaction',
      );
    }
    emit(
      ReactionLoaded(
        ReactionSummary(counts: nextCounts, myReaction: nextMyReaction),
      ),
    );

    try {
      await _repository.toggleReaction(
        answerId: answerId,
        userId: userId,
        reaction: reaction,
      );

      final fresh = await _repository.getReactionSummary(
        answerId: answerId,
        userId: userId,
      );

      if (isClosed) return;
      emit(ReactionLoaded(fresh));
      debugPrint(
        '[ReactionCubit][confirmed] answerId=$answerId, myReaction=${fresh.myReaction}, total=${fresh.total}',
      );
    } catch (e) {
      debugPrint('[ReactionCubit][rollback] answerId=$answerId: $e');
      if (isClosed) return;
      emit(
        ReactionFailure(
          '$e',
          fallbackSummary: ReactionSummary(
            counts: previousCounts,
            myReaction: previousReaction,
          ),
        ),
      );
    } finally {
      _isToggling = false;
    }
  }
}
