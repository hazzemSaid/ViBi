import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/usecases/fetch_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:vibi/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._fetchUserProfileUseCase,
    this._updateUserProfileUseCase,
    this._uploadProfileImageUseCase,
  ) : super(const ProfileInitial());

  final FetchUserProfileUseCase _fetchUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  UserProfile? get currentProfile {
    final current = state;
    if (current is ProfileLoaded) return current.profile;
    if (current is ProfileSaving) return current.profile;
    if (current is ProfileFailure) return current.profile;
    return null;
  }

  Future<UserProfile?> load(String uid) async {
    emit(const ProfileLoading());
    final profile = await _fetchUserProfileUseCase(uid);
    return profile.fold(
      (error) {
        emit(ProfileFailure(error, profile: null));
        return null;
      },
      (profile) {
        emit(ProfileLoaded(profile));
        return profile;
      },
    );
  }

  Future<bool> updateProfile(UserProfile profile) async {
    emit(ProfileSaving(profile));
    final result = await _updateUserProfileUseCase(profile);
    return result.fold(
      (error) {
        emit(ProfileFailure(error, profile: profile));
        return false;
      },
      (_) {
        emit(ProfileLoaded(profile));
        return true;
      },
    );
  }

  Future<Either<String, String>> uploadPublicProfileImage(
    String uid,
    File image,
    int slot,
  ) {
    return _uploadProfileImageUseCase(uid, image, slot);
  }
}
