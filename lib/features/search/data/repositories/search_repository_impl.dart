import 'package:vibi/features/search/data/datasources/graphql_search_datasource.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final GraphQLSearchDataSource _dataSource;

  SearchRepositoryImpl(this._dataSource);

  @override
  Future<List<UserSearchResult>> searchUsers(String query) async {
    return await _dataSource.searchUsers(query);
  }

  @override
  Future<List<ContentSearchResult>> searchContent(String query) async {
    return await _dataSource.searchContent(query);
  }
}
