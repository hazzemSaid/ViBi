class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final bool isAnonymous;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.emailVerified = false,
    this.isAnonymous = false,
  });
}
