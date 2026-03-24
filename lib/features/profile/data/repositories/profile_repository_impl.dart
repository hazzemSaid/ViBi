import 'dart:io';

import 'package:vibi/features/profile/data/models/user_profile_model.dart';
import 'package:vibi/features/profile/data/sources/graphql_profile_datasource.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final GraphQLProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    return await _dataSource.fetchProfile(uid);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = UserProfileModel(
      uid: profile.uid,
      name: profile.name,
      username: profile.username,
      bio: profile.bio,
      profileImageUrl: profile.profileImageUrl,
      updatedAt: DateTime.now(),
      followers_count: profile.followers_count,
      following_count: profile.following_count,
      answers_count: profile.answers_count,
      isPrivate: profile.isPrivate,
      allowAnonymousQuestions: profile.allowAnonymousQuestions,
      publicProfileEnabled: profile.publicProfileEnabled,
      publicThemeKey: profile.publicThemeKey,
      publicCtaText: profile.publicCtaText,
    );
    await _dataSource.updateProfile(model);
  }

  @override
  Future<String> uploadProfileImage(String uid, File image) async {
    return await _dataSource.uploadProfileImage(uid, image);
  }
}
