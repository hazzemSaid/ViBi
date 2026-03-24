import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/social/domain/repositories/follow_repository.dart';

class FollowCubit extends Cubit<ViewState<void>> {
  FollowCubit(this._repository) : super(const ViewState());
  final FollowRepository _repository;

  Future<void> followUser(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.followUser(currentUserId, userId);
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> unfollowUser(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.unfollowUser(currentUserId, userId);
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> requestFollow(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _repository.requestFollow(currentUserId, userId);
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}
