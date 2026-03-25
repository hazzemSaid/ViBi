import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/profile/data/sources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/domain/entities/answered_question.dart';
import 'package:vibi/features/profile/domain/entities/follower_user.dart';
import 'package:vibi/features/profile/domain/entities/following_user.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class UserProfileCubit extends Cubit<ViewState<UserProfile?>> {
  UserProfileCubit(this._repository) : super(const ViewState());
  final ProfileRepository _repository;

  Future<void> load(String uid) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final profile = await _repository.fetchProfile(uid);
      emit(ViewState(status: ViewStatus.success, data: profile));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class ProfileUpdateCubit extends Cubit<ViewState<void>> {
  ProfileUpdateCubit(this._repository) : super(const ViewState());
  final ProfileRepository _repository;

  Future<void> updateProfile(UserProfile profile) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      await _repository.updateProfile(profile);
      emit(const ViewState(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class PublicProfileCubit extends Cubit<ViewState<PublicProfile?>> {
  PublicProfileCubit(this._repository) : super(const ViewState());
  final PublicProfileRepository _repository;

  Future<void> loadById(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final profile = await _repository.getPublicProfile(userId, currentUserId);
      emit(ViewState(status: ViewStatus.success, data: profile));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> loadByUsername(String username) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final profile = await _repository.getPublicProfileByUsername(
        username,
        currentUserId,
      );
      emit(ViewState(status: ViewStatus.success, data: profile));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class UserAnswersCubit extends Cubit<ViewState<List<AnsweredQuestion>>> {
  UserAnswersCubit(this._repository) : super(const ViewState());
  final PublicProfileRepository _repository;

  Future<void> load(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final answers = await _repository.getUserAnswers(userId);
      emit(ViewState(status: ViewStatus.success, data: answers));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  void patchAnswerCounts({
    required String answerId,
    int? reactionsCount,
    int? commentsCount,
  }) {
    final currentAnswers = state.data;
    if (currentAnswers == null || currentAnswers.isEmpty) return;

    final updated = currentAnswers
        .map(
          (answer) => answer.id == answerId
              ? answer.copyWith(
                  likesCount: reactionsCount ?? answer.likesCount,
                  commentsCount: commentsCount ?? answer.commentsCount,
                )
              : answer,
        )
        .toList(growable: false);

    emit(ViewState(status: ViewStatus.success, data: updated));
  }
}

class FollowersCubit extends Cubit<ViewState<List<FollowerUser>>> {
  FollowersCubit(this._dataSource) : super(const ViewState());
  final GraphQLProfileDataSource _dataSource;

  Future<void> load(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      emit(
        ViewState(
          status: ViewStatus.success,
          data: await _dataSource.getFollowers(userId),
        ),
      );
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class FollowingCubit extends Cubit<ViewState<List<FollowingUser>>> {
  FollowingCubit(this._dataSource) : super(const ViewState());
  final GraphQLProfileDataSource _dataSource;

  Future<void> load(String userId) async {
    emit(const ViewState(status: ViewStatus.loading));
    try {
      emit(
        ViewState(
          status: ViewStatus.success,
          data: await _dataSource.getFollowing(userId),
        ),
      );
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}
