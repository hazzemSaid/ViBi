import 'package:equatable/equatable.dart';

class FollowerUser extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final DateTime followedAt;

  const FollowerUser({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.followersCount,
    required this.followedAt,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, bio, followersCount, followedAt];
}
