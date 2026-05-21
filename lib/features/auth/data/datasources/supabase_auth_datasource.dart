import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibi/features/auth/data/datasources/auth_datasource.dart';
import 'package:vibi/features/auth/data/models/auth_dtos.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  SupabaseAuthDataSource({SupabaseClient? client, GoogleSignIn? googleSignIn})
    : _client = client ?? Supabase.instance.client,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId: dotenv.env['GOOGLE_CLIENT_ID'],
            serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
          );

  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials')) {
      return 'The email or password you entered is incorrect.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email address first.';
    }
    if (msg.contains('user already registered')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (msg.contains('weak password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('email not found') || msg.contains('user not found')) {
      return 'No account found with this email address.';
    }
    if (msg.contains('same password')) {
      return 'New password must be different from your current password.';
    }
    if (msg.contains('link expired') || msg.contains('token expired')) {
      return 'This link has expired. Please request a new one.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Unable to connect. Please check your internet.';
    }
    if (msg.contains('identity already linked')) {
      return 'This account is already linked to another user.';
    }
    if (msg.contains('email conflict')) {
      return 'This email is already associated with another account.';
    }

    return e.message;
  }

  @override
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  @override
  Future<Either<String, User>> signInWithEmailPassword(SignInDto dto) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: dto.email,
        password: dto.password,
      );
      if (res.user == null) return left('Sign in failed');
      return right(res.user!);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Sign in failed. Please try again.');
    }
  }

  @override
  Future<Either<String, User>> signUpWithEmailPassword(SignUpDto dto) async {
    try {
      final res = await _client.auth.signUp(
        email: dto.email,
        password: dto.password,
        data: dto.data,
      );
      if (res.user == null) return left('Sign up failed');
      return right(res.user!);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Sign up failed. Please try again.');
    }
  }

  @override
  Future<Either<String, User>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return left('Google sign-in aborted');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return left('No ID token received from Google');

      final res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      if (res.user == null) return left('Google sign-in failed');
      return right(res.user!);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Google sign-in failed. Please try again.');
    }
  }

  @override
  Future<Either<String, User>> signInAnonymously() async {
    try {
      final res = await _client.auth.signInAnonymously();
      if (res.user == null) return left('Anonymous sign-in failed');
      return right(res.user!);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Anonymous sign-in failed. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _client.removeAllChannels();
      await Future.wait([_client.auth.signOut(), _googleSignIn.signOut()]);
      return right(null);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Sign out failed. Please try again.');
    }
  }

  @override
  Future<Either<String, void>> sendEmailVerification() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return left('No signed-in user to resend email to');
      await _client.auth.resend(type: OtpType.signup, email: email);
      return right(null);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Failed to send verification email.');
    }
  }

  @override
  Future<Either<String, void>> reloadUser() async {
    try {
      await _client.auth.refreshSession();
      return right(null);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Failed to reload user.');
    }
  }

  @override
  Future<Either<String, void>> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: null);
      return right(null);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Failed to send reset email.');
    }
  }

  @override
  Future<Either<String, void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return right(null);
    } on AuthException catch (e) {
      return left(_mapAuthError(e));
    } catch (e) {
      return left('Failed to update password.');
    }
  }

  @override
  Future<Either<String, void>> verifyOtp(
    String email,
    String token,
    OtpType type,
  ) async {
    if (kDebugMode) {
      debugPrint(
        'SupabaseAuthDataSource.verifyOtp type=$type emailProvided=${email.trim().isNotEmpty}',
      );
    }
    try {
      if (type == OtpType.recovery) {
        if (email.trim().isNotEmpty) {
          await _client.auth.verifyOTP(email: email, token: token, type: type);
        } else {
          await _client.auth.verifyOTP(token: token, type: type);
        }
      } else {
        await _client.auth.verifyOTP(email: email, token: token, type: type);
      }
      return right(null);
    } on AuthException catch (e) {
      if (kDebugMode) {
        debugPrint('SupabaseAuthDataSource.verifyOtp auth error: ${e.message}');
      }
      return left(_mapAuthError(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SupabaseAuthDataSource.verifyOtp unexpected error: $e');
      }
      return left('Failed to verify code.');
    }
  }
}
