import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';

class ReactionCubit extends Cubit<ViewState<ReactionSummary>> {
  ReactionCubit(this._repository, {String? Function()? currentUserIdProvider})
    : _currentUserIdProvider =
          currentUserIdProvider ??
          (() => Supabase.instance.client.auth.currentUser?.id),
      super(const ViewState(status: ViewStatus.loading));

  final ReactionsRepository _repository;
  final String? Function() _currentUserIdProvider;
  bool _isToggling = false;

  Future<void> load(String answerId) async {
    try {
      emit(const ViewState(status: ViewStatus.loading));
      final userId = _currentUserIdProvider();
      final summary = await _repository.getReactionSummary(
        answerId: answerId,
        userId: userId,
      );
      emit(ViewState(status: ViewStatus.success, data: summary));
    } catch (e) {
      debugPrint('[ReactionCubit] load failed for answerId=$answerId: $e');
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
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

    ReactionSummary? currentSummary = state.data;
    if (currentSummary == null) {
      debugPrint(
        '[ReactionCubit] state.data is null on toggle; status=${state.status}, error=${state.errorMessage}. Fetching summary first.',
      );
      try {
        currentSummary = await _repository.getReactionSummary(
          answerId: answerId,
          userId: userId,
        );
        emit(ViewState(status: ViewStatus.success, data: currentSummary));
      } catch (e) {
        debugPrint('[ReactionCubit] pre-toggle summary fetch failed: $e');
        emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
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
      ViewState(
        status: ViewStatus.success,
        data: ReactionSummary(counts: nextCounts, myReaction: nextMyReaction),
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

      emit(ViewState(status: ViewStatus.success, data: fresh));
      debugPrint(
        '[ReactionCubit][confirmed] answerId=$answerId, myReaction=${fresh.myReaction}, total=${fresh.total}',
      );
    } catch (e) {
      debugPrint('[ReactionCubit][rollback] answerId=$answerId: $e');
      emit(
        ViewState(
          status: ViewStatus.failure,
          errorMessage: '$e',
          data: ReactionSummary(
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
