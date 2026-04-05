import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> call(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}
