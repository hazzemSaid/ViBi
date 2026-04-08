import 'package:equatable/equatable.dart';
import 'package:vibi/features/home/domain/entities/feed_item.dart';

sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<FeedItem> items;
  final bool hasMore;

  const FeedLoaded(this.items, {required this.hasMore});

  @override
  List<Object?> get props => [items, hasMore];
}

class FeedFailure extends FeedState {
  final String message;
  final List<FeedItem>? items;

  const FeedFailure(this.message, {this.items});

  @override
  List<Object?> get props => [message, items];
}
