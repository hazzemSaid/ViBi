import 'package:equatable/equatable.dart';

enum ViewStatus { initial, loading, success, failure }

class ViewState<T> extends Equatable {
  const ViewState({
    this.status = ViewStatus.initial,
    this.data,
    this.errorMessage,
  });

  final ViewStatus status;
  final T? data;
  final String? errorMessage;

  bool get isLoading => status == ViewStatus.loading;
  bool get hasError => status == ViewStatus.failure;

  ViewState<T> copyWith({
    ViewStatus? status,
    T? data,
    String? errorMessage,
  }) {
    return ViewState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
