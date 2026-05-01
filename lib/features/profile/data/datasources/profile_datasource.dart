import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/data/models/answered_question_model.dart';
import 'package:vibi/features/profile/data/models/public_profile_model.dart';
import 'package:vibi/features/profile/data/models/user_profile_model.dart';

abstract class ProfileDataSource {
  Future<Either<String, UserProfileModel>> fetchProfile(String uid);

  Future<Either<String, void>> updateProfile(UserProfileModel profile);

  Future<Either<String, String>> uploadProfileImage(String uid, File image);

  Future<Either<String, List<String>>> uploadAndSaveAvatar(
    String uid,
    File image,
    List<String> currentAvatarUrls,
  );

  Future<Either<String, String>> uploadPublicProfileImage(
    String uid,
    File image,
    int slot,
  );

  Future<Either<String, PublicProfileModel>> getPublicProfile(
    String userId,
    String? currentUserId,
  );

  Future<Either<String, PublicProfileModel>> getPublicProfileByUsername(
    String username,
    String? currentUserId,
  );

  Future<Either<String, List<AnsweredQuestionModel>>> getUserAnswers(
    String userId,
  );
}
