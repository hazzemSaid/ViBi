import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({this.user, this.isLoading = true});

  final AppUser? user;
  final bool isLoading;

  @override
  List<Object?> get props => [user, isLoading];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState()) {
    _subscription = _authRepository.authStateChanges.listen(
      (user) => emit(AuthState(user: user, isLoading: false)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _subscription;

  AppUser? get currentUser => state.user;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

SupabaseAuthDataSource get supabaseAuthDataSource => getIt<SupabaseAuthDataSource>();
AuthRepository get authRepository => getIt<AuthRepository>();
