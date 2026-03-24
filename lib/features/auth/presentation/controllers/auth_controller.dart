import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends Cubit<ViewState<void>> {
  AuthController(this._authRepository) : super(const ViewState<void>());

  final AuthRepository _authRepository;

  Future<void> signInWithEmail(String email, String password) async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      await _authRepository.signInWithEmailPassword(email, password);
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
      await _authRepository.signUpWithEmailPassword(
        email,
        password,
        data: data,
      );
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      await _authRepository.signInWithGoogle();
      emit(const ViewState<void>(status: ViewStatus.success));
    } catch (e) {
      emit(ViewState<void>(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> signOut() async {
    emit(const ViewState<void>(status: ViewStatus.loading));
    try {
      await _authRepository.signOut();
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
