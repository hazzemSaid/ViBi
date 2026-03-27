import 'package:vibi/features/search/domain/entities/user_search_result.dart';

class UserSearchResultModel extends UserSearchResult {
  UserSearchResultModel({
    required super.id,
    super.name,
    super.username,
    super.bio,
    super.profileImageUrl,
    required super.followersCount,
    required super.answersCount,
    required super.isPrivate,
  });

  factory UserSearchResultModel.fromGraphQL(Map<String, dynamic> node) {
    return UserSearchResultModel(
      id: node['id'] as String,
      name: node['full_name'] as String?,
      username: node['username'] as String?,
      bio: node['bio'] as String?,
      profileImageUrl: node['avatar_url'] as String?,
      followersCount: _extractCount(
        node['followersCount'],
        fallback: node['followers_count'],
      ),
      answersCount: _extractCount(
        node['answersCount'],
        fallback: node['answers_count'],
      ),
      isPrivate: node['is_private'] as bool? ?? false,
    );
  }

  factory UserSearchResultModel.fromMap(Map<String, dynamic> map) {
    return UserSearchResultModel(
      id: map['id'] as String,
      name: map['full_name'] as String?,
      username: map['username'] as String?,
      bio: map['bio'] as String?,
      profileImageUrl: map['avatar_url'] as String?,
      followersCount: _extractCount(map['followers_count']),
      answersCount: _extractCount(map['answers_count']),
      isPrivate: map['is_private'] as bool? ?? false,
    );
  }

  static int _extractCount(dynamic value, {dynamic fallback}) {
    if (value is int) return value;
    if (value is Map<String, dynamic>) {
      final total = value['totalCount'];
      if (total is int) return total;
      final edges = value['edges'];
      if (edges is List) return edges.length;
      return 0;
    }
    if (fallback is int) return fallback;
    return 0;
  }
}
