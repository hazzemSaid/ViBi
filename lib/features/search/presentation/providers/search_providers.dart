import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';
import 'package:vibi/features/search/presentation/providers/search_state.dart';

class UserSearchCubit extends Cubit<UserSearchState> {
  UserSearchCubit(this._repository) : super(const UserSearchInitial());
  final SearchRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const UserSearchLoaded([]));
      return;
    }
    emit(const UserSearchLoading());
    try {
      final result = await _repository.searchUsers(query);
      emit(UserSearchLoaded(result));
    } catch (e) {
      emit(UserSearchFailure('$e'));
    }
  }
}

class ContentSearchCubit extends Cubit<ContentSearchState> {
  ContentSearchCubit(this._repository) : super(const ContentSearchInitial());
  final SearchRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const ContentSearchLoaded([]));
      return;
    }
    emit(const ContentSearchLoading());
    try {
      final result = await _repository.searchContent(query);
      emit(ContentSearchLoaded(result));
    } catch (e) {
      emit(ContentSearchFailure('$e'));
    }
  }
}
