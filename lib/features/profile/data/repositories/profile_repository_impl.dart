import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/data/datasources/profile_datasource.dart';
import 'package:vibi/features/profile/data/models/user_profile_model.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, UserProfile>> fetchProfile(String uid) async {
    final result = await _dataSource.fetchProfile(uid);
    return result;
  }

  @override
  Future<Either<String, void>> updateProfile(UserProfile profile) async {
    final model = UserProfileModel(
      uid: profile.uid,
      name: profile.name,
      username: profile.username,
      bio: profile.bio,
      avatarUrls: profile.avatarUrls,
      updatedAt: DateTime.now(),
      followers_count: profile.followers_count,
      following_count: profile.following_count,
      answers_count: profile.answers_count,
      isPrivate: profile.isPrivate,
      allowAnonymousQuestions: profile.allowAnonymousQuestions,
      publicProfileEnabled: profile.publicProfileEnabled,
      publicCtaText: profile.publicCtaText,
      favColor: profile.favColor,
      questionPlaceholder: profile.questionPlaceholder,
      showSocialIcons: profile.showSocialIcons,
      statusText: profile.statusText,
      publicFontFamily: profile.publicFontFamily,
      isVerified: profile.isVerified,
    );
    final result = await _dataSource.updateProfile(model);
    return result;
  }

  @override
  Future<Either<String, String>> uploadProfileImage(
    String uid,
    File image,
  ) async {
    final result = await _dataSource.uploadProfileImage(uid, image);
    return result;
  }

  @override
  Future<Either<String, List<String>>> uploadAndSaveAvatar(
    String uid,
    File image,
    List<String> currentAvatarUrls,
  ) async {
    final result = await _dataSource.uploadAndSaveAvatar(
      uid,
      image,
      currentAvatarUrls,
    );
    return result;
  }

  @override
  Future<Either<String, String>> uploadPublicProfileImage(
    String uid,
    File image,
    int slot,
  ) async {
    final result = await _dataSource.uploadPublicProfileImage(uid, image, slot);
    return result;
  }
}
