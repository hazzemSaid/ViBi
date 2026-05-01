import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class GetPublicProfileByUsernameUseCase {
  final PublicProfileRepository _repository;

  GetPublicProfileByUsernameUseCase(this._repository);

  Future<Either<String, PublicProfile>> call(String username) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return _repository.getPublicProfileByUsername(username, currentUserId);
  }
}
