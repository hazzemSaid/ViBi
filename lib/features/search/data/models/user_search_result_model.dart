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
      followersCount: node['followers_count'] as int? ?? 0,
      answersCount: node['answers_count'] as int? ?? 0,
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
      followersCount: map['followers_count'] as int? ?? 0,
      answersCount: map['answers_count'] as int? ?? 0,
      isPrivate: map['is_private'] as bool? ?? false,
    );
  }
}
