import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/reactions/domain/entities/comment_item.dart';
import 'package:vibi/features/reactions/domain/repositories/reactions_repository.dart';

class CommentsState extends Equatable {
  const CommentsState({
    this.viewState = const ViewState(status: ViewStatus.loading),
    this.isSending = false,
  });

  final ViewState<List<CommentItem>> viewState;
  final bool isSending;

  CommentsState copyWith({
    ViewState<List<CommentItem>>? viewState,
    bool? isSending,
  }) {
    return CommentsState(
      viewState: viewState ?? this.viewState,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [viewState, isSending];
}

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository, {String? Function()? currentUserIdProvider})
    : _currentUserIdProvider =
          currentUserIdProvider ??
          (() => Supabase.instance.client.auth.currentUser?.id),
      super(const CommentsState());

  final ReactionsRepository _repository;
  final String? Function() _currentUserIdProvider;

  Future<void> load(String answerId) async {
    try {
      emit(
        state.copyWith(viewState: const ViewState(status: ViewStatus.loading)),
      );

      final comments = await _repository.getComments(answerId);
      emit(
        state.copyWith(
          viewState: ViewState(status: ViewStatus.success, data: comments),
        ),
      );
    } catch (e) {
      debugPrint('[CommentsCubit] load failed for answerId=$answerId: $e');
      emit(
        state.copyWith(
          viewState: ViewState(status: ViewStatus.failure, errorMessage: '$e'),
        ),
      );
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

    final current = List<CommentItem>.from(state.viewState.data ?? []);
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
      state.copyWith(
        isSending: true,
        viewState: ViewState(
          status: ViewStatus.success,
          data: [...current, optimistic],
        ),
      ),
    );

    if (kDebugMode) {
      debugPrint(
        '[CommentsCubit][optimistic] answerId=$answerId, optimisticCount=${current.length + 1}',
      );
    }

    try {
      await _repository.addComment(
        answerId: answerId,
        userId: userId,
        body: text,
      );

      final fresh = await _repository.getComments(answerId);
      emit(
        state.copyWith(
          isSending: false,
          viewState: ViewState(status: ViewStatus.success, data: fresh),
        ),
      );
      debugPrint(
        '[CommentsCubit][confirmed] answerId=$answerId, count=${fresh.length}',
      );
    } catch (e) {
      debugPrint('[CommentsCubit][rollback] answerId=$answerId: $e');
      emit(
        state.copyWith(
          isSending: false,
          viewState: ViewState(
            status: ViewStatus.failure,
            errorMessage: '$e',
            data: current,
          ),
        ),
      );
    }
  }
}
