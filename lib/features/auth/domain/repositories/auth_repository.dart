import 'package:dartz/dartz.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<Either<String, AppUser>> signInWithEmailPassword(String email, String password);
  Future<Either<String, AppUser>> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  });
  Future<Either<String, AppUser>> signInWithGoogle();
  Future<Either<String, void>> signOut();
  Future<Either<String, void>> sendEmailVerification();
  Future<Either<String, void>> reloadUser();
}
