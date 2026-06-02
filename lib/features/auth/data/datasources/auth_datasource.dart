import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/auth/data/models/auth_dtos.dart';

abstract class AuthDataSource {
  Stream<User?> get authStateChanges;
  Future<Either<String, User>> signInWithEmailPassword(SignInDto dto);
  Future<Either<String, User>> signUpWithEmailPassword(SignUpDto dto);
  Future<Either<String, User>> signInWithGoogle();
  Future<Either<String, User>> signInAnonymously();
  Future<Either<String, void>> signOut();
  Future<Either<String, void>> sendEmailVerification();
  Future<Either<String, void>> reloadUser();
  Future<Either<String, void>> resetPasswordForEmail(String email);
  Future<Either<String, void>> updatePassword(String newPassword);
  Future<Either<String, void>> verifyOtp(
    String email,
    String token,
    OtpType type,
  );
}
