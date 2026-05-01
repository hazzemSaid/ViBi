import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

/// Use case for fetching a user's profile information.
///
/// This use case retrieves the complete profile data for a given user ID
/// by delegating to the [ProfileRepository].
class FetchUserProfileUseCase {
  final ProfileRepository _repository;

  FetchUserProfileUseCase(this._repository);

  /// Fetches a user profile by their unique identifier.
  ///
  /// [uid] is the unique user ID to fetch the profile for.
  ///
  /// Returns the [UserProfile] if found, or `null` if not found.
  Future<Either<String, UserProfile>> call(String uid) {
    return _repository.fetchProfile(uid);
  }
}
