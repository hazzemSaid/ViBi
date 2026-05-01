import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for updating a user's profile information.
///
/// This use case updates the profile data by delegating to the [ProfileRepository].
class UpdateUserProfileUseCase {
  final ProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  /// Updates an existing user profile with new data.
  ///
  /// [profile] is the updated [UserProfile] object containing the new data.
  ///
  /// Throws an exception if the update operation fails.
  Future<Either<String, void>> call(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}
