import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/auth/domain/entities/app_user.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_state.dart';

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
