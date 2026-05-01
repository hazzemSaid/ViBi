class SignInDto {
  final String email;
  final String password;

  const SignInDto({required this.email, required this.password});
}

class SignUpDto {
  final String email;
  final String password;
  final Map<String, dynamic>? data;

  const SignUpDto({required this.email, required this.password, this.data});
}
