import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/social/domain/repositories/follow_repository.dart';
import 'package:vibi/features/social/presentation/providers/follow_state.dart';

class FollowCubit extends Cubit<FollowActionState> {
  FollowCubit(this._repository) : super(const FollowActionInitial());
  final FollowRepository _repository;

  Future<void> followUser(String userId) async {
    emit(const FollowActionLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.followUser(currentUserId, userId);
      emit(const FollowActionSuccess());
    } catch (e) {
      emit(FollowActionFailure('$e'));
    }
  }

  Future<void> unfollowUser(String userId) async {
    emit(const FollowActionLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.unfollowUser(currentUserId, userId);
      emit(const FollowActionSuccess());
    } catch (e) {
      emit(FollowActionFailure('$e'));
    }
  }

  Future<void> requestFollow(String userId) async {
    emit(const FollowActionLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.requestFollow(currentUserId, userId);
      emit(const FollowActionSuccess());
    } catch (e) {
      emit(FollowActionFailure('$e'));
    }
  }
}
