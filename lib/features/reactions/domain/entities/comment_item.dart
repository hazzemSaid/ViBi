import 'package:equatable/equatable.dart';

class CommentItem extends Equatable {
  const CommentItem({
    required this.id,
    required this.answerId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.username,
    this.avatarUrl,
    this.isOptimistic = false,
  });

  final String id;
  final String answerId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final String? username;
  final String? avatarUrl;
  final bool isOptimistic;

  @override
  List<Object?> get props => [
    id,
    answerId,
    userId,
    body,
    createdAt,
    username,
    avatarUrl,
    isOptimistic,
  ];
}
