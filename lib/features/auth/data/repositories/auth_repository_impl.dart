import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource dataSource;

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
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    final user = await dataSource.signInWithEmailPassword(email, password);
    return _mapUser(user);
  }

  @override
  Future<AppUser> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    final user = await dataSource.signUpWithEmailPassword(
      email,
      password,
      data: data,
    );
    return _mapUser(user);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final user = await dataSource.signInWithGoogle();
    return _mapUser(user);
  }

  @override
  Future<void> signOut() => dataSource.signOut();

  @override
  Future<void> sendEmailVerification() => dataSource.sendEmailVerification();

  @override
  Future<void> reloadUser() => dataSource.reloadUser();
}
