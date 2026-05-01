import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/auth/data/datasources/auth_datasource.dart';
import 'package:vibi/features/auth/data/models/auth_dtos.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName:
          user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String?,
      // Supabase sets emailConfirmedAt once the user clicks the confirmation link
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return dataSource.authStateChanges.map(
      (user) => user == null ? null : _mapUser(user),
    );
  }

  @override
  Future<Either<String, AppUser>> signInWithEmailPassword(String email, String password) async {
    final result = await dataSource.signInWithEmailPassword(SignInDto(email: email, password: password));
    return result.map((user) => _mapUser(user));
  }

  @override
  Future<Either<String, AppUser>> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    final result = await dataSource.signUpWithEmailPassword(SignUpDto(email: email, password: password, data: data));
    return result.map((user) => _mapUser(user));
  }

  @override
  Future<Either<String, AppUser>> signInWithGoogle() async {
    final result = await dataSource.signInWithGoogle();
    return result.map((user) => _mapUser(user));
  }

  @override
  Future<Either<String, void>> signOut() => dataSource.signOut();

  @override
  Future<Either<String, void>> sendEmailVerification() => dataSource.sendEmailVerification();

  @override
  Future<Either<String, void>> reloadUser() => dataSource.reloadUser();
}
