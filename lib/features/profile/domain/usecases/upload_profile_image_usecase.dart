import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:vibi/features/profile/domain/repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository _repository;

  UploadProfileImageUseCase(this._repository);

  Future<Either<String, String>> call(String uid, File image, int slot) {
    return _repository.uploadPublicProfileImage(uid, image, slot);
  }
}
