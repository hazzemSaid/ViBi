import 'package:vibi/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<AppUser> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  });
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
}
