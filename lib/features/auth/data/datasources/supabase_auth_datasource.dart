import 'package:dartz/dartz.dart';
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
    } catch (e) {
      return left('Sign in failed: $e');
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
    } catch (e) {
      return left('Sign up failed: $e');
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
    } catch (e) {
      return left('Google sign-in failed: $e');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _client.removeAllChannels();
      await Future.wait([_client.auth.signOut(), _googleSignIn.signOut()]);
      return right(null);
    } catch (e) {
      return left('Sign out failed: $e');
    }
  }

  @override
  Future<Either<String, void>> sendEmailVerification() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return left('No signed-in user to resend email to');
      await _client.auth.resend(type: OtpType.signup, email: email);
      return right(null);
    } catch (e) {
      return left('Failed to send verification email: $e');
    }
  }

  @override
  Future<Either<String, void>> reloadUser() async {
    try {
      await _client.auth.refreshSession();
      return right(null);
    } catch (e) {
      return left('Failed to reload user: $e');
    }
  }
}
