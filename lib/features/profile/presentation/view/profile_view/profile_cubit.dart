import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/profile/data/sources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/profile_cubit_state.dart';
import 'package:vibi/features/profile/presentation/view/profile_view/public_profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._fetchUserProfileUseCase,
    this._updateUserProfileUseCase,
    this._profileRepository,
  ) : super(const ProfileInitial());

  final FetchUserProfileUseCase _fetchUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final ProfileRepository _profileRepository;

  UserProfile? get currentProfile {
    final current = state;
    if (current is ProfileLoaded) return current.profile;
    if (current is ProfileSaving) return current.profile;
    if (current is ProfileFailure) return current.profile;
    return null;
  }

  Future<UserProfile?> load(String uid) async {
    emit(const ProfileLoading());
    try {
      final profile = await _fetchUserProfileUseCase(uid);
      if (profile == null) {
        emit(const ProfileFailure('Profile not found.'));
        return null;
      }
      emit(ProfileLoaded(profile));
      return profile;
    } catch (e) {
      emit(ProfileFailure('$e', profile: currentProfile));
      return null;
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    emit(ProfileSaving(profile));
    try {
      await _updateUserProfileUseCase(profile);
      emit(ProfileLoaded(profile));
      return true;
    } catch (e) {
      emit(ProfileFailure('$e', profile: profile));
      return false;
    }
  }

  Future<String> uploadPublicProfileImage(String uid, File image, int slot) {
    return _profileRepository.uploadPublicProfileImage(uid, image, slot);
  }
}

class PublicProfileCubit extends Cubit<PublicProfileState> {
  PublicProfileCubit(this._repository) : super(const PublicProfileInitial());
  final PublicProfileRepository _repository;

  Future<void> loadById(String userId) async {
    emit(const PublicProfileLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final profile = await _repository.getPublicProfile(userId, currentUserId);
      emit(PublicProfileLoaded(profile));
    } catch (e) {
      emit(PublicProfileFailure('$e'));
    }
  }

  Future<void> loadByUsername(String username) async {
    emit(const PublicProfileLoading());
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final profile = await _repository.getPublicProfileByUsername(
        username,
        currentUserId,
      );
      emit(PublicProfileLoaded(profile));
    } catch (e) {
      emit(PublicProfileFailure('$e'));
    }
  }
}

class UserAnswersCubit extends Cubit<UserAnswersState> {
  UserAnswersCubit(this._repository) : super(const UserAnswersInitial());
  final PublicProfileRepository _repository;

  Future<void> load(String userId) async {
    emit(const UserAnswersLoading());
    try {
      final answers = await _repository.getUserAnswers(userId);
      emit(UserAnswersLoaded(answers));
    } catch (e) {
      emit(UserAnswersFailure('$e'));
    }
  }

  void patchAnswerCounts({
    required String answerId,
    int? reactionsCount,
    int? commentsCount,
  }) {
    final currentState = state;
    if (currentState is! UserAnswersLoaded) return;
    
    final currentAnswers = currentState.answers;
    if (currentAnswers.isEmpty) return;

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

    emit(UserAnswersLoaded(updated));
  }
}

class FollowersCubit extends Cubit<FollowersState> {
  FollowersCubit(this._dataSource) : super(const FollowersInitial());
  final GraphQLProfileDataSource _dataSource;

  Future<void> load(String userId) async {
    emit(const FollowersLoading());
    try {
      final followers = await _dataSource.getFollowers(userId);
      emit(FollowersLoaded(followers));
    } catch (e) {
      emit(FollowersFailure('$e'));
    }
  }
}

class FollowingCubit extends Cubit<FollowingState> {
  FollowingCubit(this._dataSource) : super(const FollowingInitial());
  final GraphQLProfileDataSource _dataSource;

  Future<void> load(String userId) async {
    emit(const FollowingLoading());
    try {
      final following = await _dataSource.getFollowing(userId);
      emit(FollowingLoaded(following));
    } catch (e) {
      emit(FollowingFailure('$e'));
    }
  }
}
