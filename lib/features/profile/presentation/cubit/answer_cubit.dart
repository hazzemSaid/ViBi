import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/profile/domain/usecases/get_user_answers_usecase.dart';
import 'package:vibi/features/profile/presentation/cubit/answer_state.dart';

class UserAnswersCubit extends Cubit<UserAnswersState> {
  UserAnswersCubit(this._getUserAnswersUseCase)
    : super(const UserAnswersInitial());
  final GetUserAnswersUseCase _getUserAnswersUseCase;

  Future<void> load(String userId) async {
    emit(const UserAnswersLoading());
    final answers = await _getUserAnswersUseCase(userId);
    answers.fold(
      (error) => emit(UserAnswersFailure(error)),
      (answers) => emit(UserAnswersLoaded(answers)),
    );
  }

  void patchAnswerCounts({
    required String answerId,
    int? reactionsCount,
    int? commentsCount,
  }) {
    final currentState = state;
    if (currentState is! UserAnswersLoaded) return;

    final currentAnswers = currentState.answers;
    if (currentAnswers.isEmpty) return;

    final updated = currentAnswers
        .map(
          (answer) => answer.id == answerId
              ? answer.copyWith(
                  likesCount: reactionsCount ?? answer.likesCount,
                  commentsCount: commentsCount ?? answer.commentsCount,
                )
              : answer,
        )
        .toList(growable: false);
    emit(UserAnswersLoaded(updated));
  }
}
