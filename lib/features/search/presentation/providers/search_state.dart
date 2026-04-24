import 'package:equatable/equatable.dart';
import 'package:vibi/features/search/domain/entities/content_search_result.dart';
import 'package:vibi/features/search/domain/entities/user_search_result.dart';

// User Search State
abstract class UserSearchState extends Equatable {
  const UserSearchState();
  @override
  List<Object?> get props => [];
}

class UserSearchInitial extends UserSearchState {
  const UserSearchInitial();
}

class UserSearchLoading extends UserSearchState {
  const UserSearchLoading();
}

class UserSearchLoaded extends UserSearchState {
  final List<UserSearchResult> results;
  const UserSearchLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

class UserSearchFailure extends UserSearchState {
  final String message;
  const UserSearchFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Content Search State
abstract class ContentSearchState extends Equatable {
  const ContentSearchState();
  @override
  List<Object?> get props => [];
}

class ContentSearchInitial extends ContentSearchState {
  const ContentSearchInitial();
}

class ContentSearchLoading extends ContentSearchState {
  const ContentSearchLoading();
}

class ContentSearchLoaded extends ContentSearchState {
  final List<ContentSearchResult> results;
  const ContentSearchLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

class ContentSearchFailure extends ContentSearchState {
  final String message;
  const ContentSearchFailure(this.message);
  @override
  List<Object?> get props => [message];
}
