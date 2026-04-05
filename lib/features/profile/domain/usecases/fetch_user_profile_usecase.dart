import 'package:vibi/features/profile/domain/entities/user_profile.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

class FetchUserProfileUseCase {
  final ProfileRepository _repository;

  FetchUserProfileUseCase(this._repository);

  Future<UserProfile?> call(String uid) {
    return _repository.fetchProfile(uid);
  }
}
