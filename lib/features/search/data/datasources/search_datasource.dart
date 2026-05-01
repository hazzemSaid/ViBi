import 'package:dartz/dartz.dart';
import 'package:vibi/features/search/data/models/content_search_result_model.dart';
import 'package:vibi/features/search/data/models/user_search_result_model.dart';

abstract class SearchDataSource {
  Future<Either<String, List<UserSearchResultModel>>> searchUsers(String query);
  Future<Either<String, List<ContentSearchResultModel>>> searchContent(String query);
}
