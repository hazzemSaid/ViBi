import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/profile/domain/entities/public_profile.dart';
import 'package:vibi/features/profile/domain/repositories/public_profile_repository.dart';

class GetPublicProfileUseCase {
  final PublicProfileRepository _repository;

  GetPublicProfileUseCase(this._repository);

  Future<Either<String, PublicProfile>> call(String uid) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return _repository.getPublicProfile(uid, currentUserId);
  }
}
