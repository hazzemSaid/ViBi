import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';

abstract class SearchRepository {
  Future<List<UserSearchResult>> searchUsers(String query);
  Future<List<ContentSearchResult>> searchContent(String query);
}
