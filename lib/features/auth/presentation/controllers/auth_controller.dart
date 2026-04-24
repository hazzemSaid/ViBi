import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/services/push_notification_service.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends Cubit<ViewState<void>> {
  AuthController(this._authRepository, this._notificationService)
    : super(const ViewState<void>());

  final AuthRepository _authRepository;
  final PushNotificationService _notificationService;

  Future<void> signInWithEmail(String email, String password) async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      final user = await _authRepository.signInWithEmailPassword(email, password);
      await _notificationService.updateUserId(user.id);
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email,
        password,
        data: data,
      );
      await _notificationService.updateUserId(user.id);
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      final user = await _authRepository.signInWithGoogle();
      await _notificationService.updateUserId(user.id);
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> signOut() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      final userId = _authRepository.authStateChanges.first.then((user) => user?.id);
      await _authRepository.signOut();
      final id = await userId;
      if (id != null) {
        await _notificationService.clearUserId(id);
      }
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> sendEmailVerification() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      await _authRepository.sendEmailVerification();
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> reloadUser() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      await _authRepository.reloadUser();
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}
