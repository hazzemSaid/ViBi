import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/domain/usecases/get_public_profile_by_username_usecase.dart';
import 'package:vibi/features/profile/domain/usecases/get_public_profile_usecase.dart';
import 'package:vibi/features/profile/presentation/cubit/public_profile_state.dart';

class PublicProfileCubit extends Cubit<PublicProfileState> {
  PublicProfileCubit({
    required GetPublicProfileUseCase getPublicProfileUseCase,
    required GetPublicProfileByUsernameUseCase
    getPublicProfileByUsernameUseCase,
  }) : _getPublicProfileUseCase = getPublicProfileUseCase,
       _getPublicProfileByUsernameUseCase = getPublicProfileByUsernameUseCase,
       super(const PublicProfileInitial());
  final GetPublicProfileUseCase _getPublicProfileUseCase;
  final GetPublicProfileByUsernameUseCase _getPublicProfileByUsernameUseCase;
  Future<void> loadById(String userId) async {
    emit(const PublicProfileLoading());
    final profileuser = await _getPublicProfileUseCase(userId);
    profileuser.fold(
      (error) => emit(PublicProfileFailure(error)),
      (profile) => emit(PublicProfileLoaded(profile)),
    );
  }

  Future<void> loadByUsername(String username) async {
    emit(const PublicProfileLoading());
    final profile = await _getPublicProfileByUsernameUseCase(username);
    profile.fold(
      (error) => emit(PublicProfileFailure(error)),
      (profile) => emit(PublicProfileLoaded(profile)),
    );
  }
}
