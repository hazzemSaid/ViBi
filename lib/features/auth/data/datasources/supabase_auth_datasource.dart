import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthDataSource {
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

  /// Emits the current user on subscription and on every auth state change.
  /// Emits null when the user is signed out.
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  Future<User> signInWithEmailPassword(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) throw Exception('Sign in failed');
    return res.user!;
  }

  /// Signs up a new user and sends a verification email.
  /// NOTE: if Supabase email confirmation is enabled, the session will be null
  /// until the user clicks the confirmation link. The returned [User] will have
  /// [emailConfirmedAt] == null in that case.
  Future<User> signUpWithEmailPassword(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    if (res.user == null) throw Exception('Sign up failed');
    return res.user!;
  }

  /// Signs in with Google using the native sign-in sheet, then exchanges the
  /// Google ID token for a Supabase session via [signInWithIdToken].
  Future<User> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in aborted');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('No ID token received from Google');

    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
    if (res.user == null) throw Exception('Google sign-in failed');
    return res.user!;
  }

  Future<void> signOut() async {
    await Future.wait([_client.auth.signOut(), _googleSignIn.signOut()]);
  }

  /// Resends the confirmation email. Requires an active (but unconfirmed) user.
  Future<void> sendEmailVerification() async {
    final email = _client.auth.currentUser?.email;
    if (email == null) throw Exception('No signed-in user to resend email to');
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  /// Refreshes the session to pick up the latest [emailConfirmedAt] state from
  /// the server after the user clicks their confirmation link.
  Future<void> reloadUser() async {
    await _client.auth.refreshSession();
  }
}
