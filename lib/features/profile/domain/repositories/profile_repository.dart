import 'dart:io';

import 'package:vibi/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// Fetches a user profile by their unique identifier.
  ///
  /// [uid] is the unique user ID to fetch the profile for.
  ///
  /// Returns the [UserProfile] if found, or `null` if the profile doesn't exist.
  Future<UserProfile?> fetchProfile(String uid);

  /// Updates an existing user profile with new data.
  ///
  /// [profile] is the updated [UserProfile] object containing the new data.
  ///
  /// Throws an exception if the update fails.
  Future<void> updateProfile(UserProfile profile);

  /// Uploads a profile image to Supabase storage.
  ///
  /// [uid] is the user ID used as the storage path prefix.
  /// [image] is the image file to upload.
  ///
  /// Returns the public URL of the uploaded image.
  ///
  /// Throws an exception if the upload fails.
  Future<String> uploadProfileImage(String uid, File image);

  /// Uploads a new avatar image and saves its URL to the user's avatar_urls list.
  ///
  /// [uid] is the user ID.
  /// [image] is the avatar image file to upload.
  /// [currentAvatarUrls] is the existing list of avatar URLs to append to.
  ///
  /// Returns the updated list of avatar URLs including the newly uploaded one.
  ///
  /// Throws an exception if the upload or save operation fails.
  Future<List<String>> uploadAndSaveAvatar(
    String uid,
    File image,
    List<String> currentAvatarUrls,
  );

  /// Uploads a public profile image to one of three available slots.
  ///
  /// [uid] is the user ID.
  /// [image] is the profile image file to upload.
  /// [slot] is the slot number (1-3) where the image will be stored.
  ///
  /// Returns the public URL of the uploaded image.
  ///
  /// Throws an [ArgumentError] if slot is not between 1 and 3.
  /// Throws an exception if the upload fails.
  Future<String> uploadPublicProfileImage(String uid, File image, int slot);
}
