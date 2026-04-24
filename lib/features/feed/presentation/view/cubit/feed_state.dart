import 'package:equatable/equatable.dart';
import 'package:vibi/features/feed/domain/entities/feed_item.dart';

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

extension FeedStateX on FeedState {
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(List<FeedItem> items, bool hasMore) loaded,
    required R Function(String message, List<FeedItem>? items) failure,
  }) {
    return switch (this) {
      FeedInitial() => initial(),
      FeedLoading() => loading(),
      FeedLoaded(:final items, :final hasMore) => loaded(items, hasMore),
      FeedFailure(:final message, :final items) => failure(message, items),
    };
  }
}

