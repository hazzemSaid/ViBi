import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/follow/domain/usecases/get_followers_usecase.dart';
import 'package:vibi/features/follow/presentation/cubit/followers/followers_state.dart';

class FollowersCubit extends Cubit<FollowersState> {
  FollowersCubit({required this.getFollowersUseCase})
    : super(FollowersInitial());

  final GetFollowersUseCase getFollowersUseCase;

  Future<void> load(String userId) async {
    emit(FollowersLoading());
    final result = await getFollowersUseCase(userId);
    result.fold(
      (failure) => emit(FollowersFailure(failure)),
      (followers) => emit(FollowersLoaded(followers)),
    );
  }
}
