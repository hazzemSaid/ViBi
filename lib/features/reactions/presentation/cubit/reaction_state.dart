import 'package:equatable/equatable.dart';
import 'package:vibi/features/reactions/domain/entities/reaction_summary.dart';

abstract class ReactionState extends Equatable {
  const ReactionState();

  @override
  List<Object?> get props => [];
}

class ReactionInitial extends ReactionState {
  const ReactionInitial();
}

class ReactionLoading extends ReactionState {
  const ReactionLoading();
}

class ReactionLoaded extends ReactionState {
  final ReactionSummary summary;
  const ReactionLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ReactionFailure extends ReactionState {
  final String message;
  final ReactionSummary? fallbackSummary;
  const ReactionFailure(this.message, {this.fallbackSummary});

  @override
  List<Object?> get props => [message, fallbackSummary];
}
