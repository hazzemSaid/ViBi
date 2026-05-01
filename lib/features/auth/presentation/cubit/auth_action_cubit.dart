import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';
export 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';

class AuthActionCubit extends Cubit<AuthActionState> {
  AuthActionCubit(this._authRepository, this._notificationService)
    : super(const AuthActionInitial());

  final AuthRepository _authRepository;
  final PushNotificationService _notificationService;

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthActionLoading());
    final result = await _authRepository.signInWithEmailPassword(email, password);
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (user) async {
        await _notificationService.updateUserId(user.id);
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    emit(const AuthActionLoading());
    final result = await _authRepository.signUpWithEmailPassword(
      email,
      password,
      data: data,
    );
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (user) async {
        await _notificationService.updateUserId(user.id);
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthActionLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (user) async {
        await _notificationService.updateUserId(user.id);
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> signOut() async {
    emit(const AuthActionLoading());
    final userId = await _authRepository.authStateChanges.first.then((user) => user?.id);
    final result = await _authRepository.signOut();
    
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) async {
        if (userId != null) {
          await _notificationService.clearUserId(userId);
        }
        emit(const AuthActionSuccess());
      },
    );
  }

  Future<void> sendEmailVerification() async {
    emit(const AuthActionLoading());
    final result = await _authRepository.sendEmailVerification();
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) => emit(const AuthActionSuccess()),
    );
  }

  Future<void> reloadUser() async {
    emit(const AuthActionLoading());
    final result = await _authRepository.reloadUser();
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) => emit(const AuthActionSuccess()),
    );
  }
}
