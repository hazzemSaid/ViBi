import 'dart:io';

import 'package:vibi/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> fetchProfile(String uid);
  Future<void> updateProfile(UserProfile profile);
  Future<String> uploadProfileImage(String uid, File image);
  Future<List<String>> uploadAndSaveAvatar(
    String uid,
    File image,
    List<String> currentAvatarUrls,
  );
  Future<String> uploadPublicProfileImage(String uid, File image, int slot);
}
