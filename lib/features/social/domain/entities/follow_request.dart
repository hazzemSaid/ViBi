class FollowRequest {
  final String id;
  final String requesterId;
  final String targetId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  FollowRequest({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
  });
}
