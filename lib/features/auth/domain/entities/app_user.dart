class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool emailVerified;
  final bool isAnonymous;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.emailVerified = false,
    this.isAnonymous = false,
  });
}
