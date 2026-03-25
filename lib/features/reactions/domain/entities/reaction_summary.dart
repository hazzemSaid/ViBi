import 'package:equatable/equatable.dart';

class ReactionSummary extends Equatable {
  const ReactionSummary({required this.counts, this.myReaction});

  final Map<String, int> counts;
  final String? myReaction;

  int get total => counts.values.fold(0, (sum, item) => sum + item);

  ReactionSummary copyWith({
    Map<String, int>? counts,
    String? myReaction,
    bool clearMyReaction = false,
  }) {
    return ReactionSummary(
      counts: counts ?? this.counts,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
    );
  }

  @override
  List<Object?> get props => [counts, myReaction];
}
