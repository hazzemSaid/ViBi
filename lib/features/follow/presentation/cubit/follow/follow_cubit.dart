import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/follow/domain/repositories/follow_repository.dart';
import 'package:vibi/features/follow/presentation/cubit/follow/follow_state.dart';

class FollowCubit extends Cubit<FollowActionState> {
  FollowCubit(this._repository) : super(const FollowActionInitial());
  final FollowRepository _repository;

  /** Performs follow action and emits success/failure states. */
  Future<void> followUser(String userId) async {
    emit(const FollowActionLoading());
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      emit(const FollowActionFailure('User not authenticated'));
      return;
    }
    final result = await _repository.followUser(currentUserId, userId);
    result.fold(
      (error) => emit(FollowActionFailure(error)),
      (_) => emit(const FollowActionSuccess()),
    );
  }

  /** Performs unfollow action and emits success/failure states. */
  Future<void> unfollowUser(String userId) async {
    emit(const FollowActionLoading());
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      emit(const FollowActionFailure('User not authenticated'));
      return;
    }
    final result = await _repository.unfollowUser(currentUserId, userId);
    result.fold(
      (error) => emit(FollowActionFailure(error)),
      (_) => emit(const FollowActionSuccess()),
    );
  }
}
