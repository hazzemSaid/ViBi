import 'package:equatable/equatable.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';

class AuthState extends Equatable {
  const AuthState({this.user, this.isLoading = true});

  final AppUser? user;
  final bool isLoading;

  @override
  List<Object?> get props => [user, isLoading];
}
