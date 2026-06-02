import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';
export 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';

class PasswordResetCubit extends Cubit<AuthActionState> {
  PasswordResetCubit(this._authRepository) : super(const AuthActionInitial());

  final AuthRepository _authRepository;

  Future<void> sendResetEmail(String email) async {
    debugPrint('PasswordResetCubit.sendResetEmail');
    emit(const AuthActionLoading());
    final result = await _authRepository.resetPasswordForEmail(email);
    result.fold(
      (error) {
        debugPrint('PasswordResetCubit.sendResetEmail failed: $error');
        emit(AuthActionFailure(error));
      },
      (_) {
        debugPrint('PasswordResetCubit.sendResetEmail success');
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> updatePassword(String newPassword) async {
    debugPrint('PasswordResetCubit.updatePassword');
    emit(const AuthActionLoading());
    final result = await _authRepository.updatePassword(newPassword);
    result.fold(
      (error) {
        debugPrint('PasswordResetCubit.updatePassword failed: $error');
        emit(AuthActionFailure(error));
      },
      (_) {
        debugPrint('PasswordResetCubit.updatePassword success');
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> verifyResetOtp(String email, String token) async {
    debugPrint('PasswordResetCubit.verifyResetOtp');
    emit(const AuthActionLoading());
    final result = await _authRepository.verifyOtp(
      email,
      token,
      AuthOtpType.recovery,
    );
    result.fold(
      (error) {
        debugPrint('PasswordResetCubit.verifyResetOtp failed: $error');
        emit(AuthActionFailure(error));
      },
      (_) {
        debugPrint('PasswordResetCubit.verifyResetOtp success');
        emit(const AuthActionSuccess());
      },
    );
  }
}
