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
    try {
      final user = await _authRepository.signInWithEmailPassword(email, password);
      await _notificationService.updateUserId(user.id);
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    emit(const AuthActionLoading());
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email,
        password,
        data: data,
      );
      await _notificationService.updateUserId(user.id);
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthActionLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      await _notificationService.updateUserId(user.id);
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }

  Future<void> signOut() async {
    emit(const AuthActionLoading());
    try {
      final userId = _authRepository.authStateChanges.first.then((user) => user?.id);
      await _authRepository.signOut();
      final id = await userId;
      if (id != null) {
        await _notificationService.clearUserId(id);
      }
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }

  Future<void> sendEmailVerification() async {
    emit(const AuthActionLoading());
    try {
      await _authRepository.sendEmailVerification();
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }

  Future<void> reloadUser() async {
    emit(const AuthActionLoading());
    try {
      await _authRepository.reloadUser();
      emit(const AuthActionSuccess());
    } catch (e) {
      emit(AuthActionFailure('$e'));
    }
  }
}
