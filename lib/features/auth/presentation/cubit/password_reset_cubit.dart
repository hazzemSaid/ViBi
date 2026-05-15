import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';
export 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';

class PasswordResetCubit extends Cubit<AuthActionState> {
  PasswordResetCubit(this._authRepository) : super(const AuthActionInitial());

  final AuthRepository _authRepository;

  Future<void> sendResetEmail(String email) async {
    emit(const AuthActionLoading());
    final result = await _authRepository.resetPasswordForEmail(email);
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) => emit(const AuthActionSuccess()),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    emit(const AuthActionLoading());
    final result = await _authRepository.updatePassword(newPassword);
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) => emit(const AuthActionSuccess()),
    );
  }
}
