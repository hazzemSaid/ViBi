import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/core/di/service_locator.dart';
import 'package:vibi/core/state/view_state.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';

class UserSearchCubit extends Cubit<ViewState<List<UserSearchResult>>> {
  UserSearchCubit(this._repository) : super(const ViewState());
  final SearchRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const ViewState(status: ViewStatus.success, data: []));
      return;
    }
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final result = await _repository.searchUsers(query);
      emit(ViewState(status: ViewStatus.success, data: result));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

class ContentSearchCubit extends Cubit<ViewState<List<ContentSearchResult>>> {
  ContentSearchCubit(this._repository) : super(const ViewState());
  final SearchRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const ViewState(status: ViewStatus.success, data: []));
      return;
    }
    emit(const ViewState(status: ViewStatus.loading));
    try {
      final result = await _repository.searchContent(query);
      emit(ViewState(status: ViewStatus.success, data: result));
    } catch (e) {
      emit(ViewState(status: ViewStatus.failure, errorMessage: '$e'));
    }
  }
}

SearchRepository get searchRepository => getIt<SearchRepository>();
