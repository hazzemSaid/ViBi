import 'package:dartz/dartz.dart';
import 'package:vibi/features/search/data/datasources/search_datasource.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';
import 'package:vibi/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDataSource _dataSource;

  SearchRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsers(String query) async {
    final result = await _dataSource.searchUsers(query);
    return result.fold(
      (error) => Left(error),
      (models) => Right(models.cast<UserSearchResult>()),
    );
  }

  @override
  Future<Either<String, List<ContentSearchResult>>> searchContent(String query) async {
    final result = await _dataSource.searchContent(query);
    return result.fold(
      (error) => Left(error),
      (models) => Right(models.cast<ContentSearchResult>()),
    );
  }
}
