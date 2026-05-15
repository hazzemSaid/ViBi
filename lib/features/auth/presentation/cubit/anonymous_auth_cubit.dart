import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';
export 'package:vibi/features/auth/presentation/cubit/auth_action_state.dart';

class AnonymousAuthCubit extends Cubit<AuthActionState> {
  AnonymousAuthCubit(this._authRepository) : super(const AuthActionInitial());

  final AuthRepository _authRepository;

  Future<void> signInAnonymously() async {
    emit(const AuthActionLoading());
    final result = await _authRepository.signInAnonymously();
    result.fold(
      (error) => emit(AuthActionFailure(error)),
      (_) => emit(const AuthActionSuccess()),
    );
  }
}
