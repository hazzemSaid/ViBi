import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/follow/domain/usecases/get_following_usecase.dart';
import 'package:vibi/features/follow/presentation/cubit/followings/followings_state.dart';

class FollowingCubit extends Cubit<FollowingState> {
  FollowingCubit({required this.getFollowingUseCase})
    : super(FollowingInitial());

  final GetFollowingUseCase getFollowingUseCase;

  Future<void> load(String userId) async {
    emit(FollowingLoading());
    final result = await getFollowingUseCase(userId);
    result.fold(
      (failure) => emit(FollowingFailure(failure)),
      (following) => emit(FollowingLoaded(following)),
    );
  }
}
