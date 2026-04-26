import 'package:supabase_flutter/supabase_flutter.dart';

/**
 * Resolves the current authenticated username from Supabase metadata.
 *
 * Takes:
 * - fallback username used when metadata and email are unavailable.
 *
 * Returns:
 * - Best-effort username string.
 *
 * Used for:
 * - Sharing profile links and answer attribution across inbox flows.
 */
String resolveCurrentUsername({String fallback = 'user'}) {
  final user = Supabase.instance.client.auth.currentUser;
  final rawUsername = (user?.userMetadata?['username'] as String?)?.trim();
  if (rawUsername != null && rawUsername.isNotEmpty) {
    return rawUsername;
  }

  final emailUsername = user?.email?.split('@').first.trim();
  if (emailUsername != null && emailUsername.isNotEmpty) {
    return emailUsername;
  }

  return fallback;
}