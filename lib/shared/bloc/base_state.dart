import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';

/// Base state class for all BLoC states
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

/// Common state mixins
mixin LoadingState {
  bool get isLoading => true;
  String? get loadingMessage => null;
}

mixin SuccessState<T> {
  bool get isSuccess => true;
  T? get data => null;
  String? get successMessage => null;
}

mixin ErrorState {
  bool get hasError => true;
  Failure? get failure => null;
  String? get errorMessage => null;
}

/// Initial state
class InitialState extends BaseState {
  const InitialState();
}

/// Loading state
class LoadingDataState extends BaseState with LoadingState {
  @override
  final String? loadingMessage;

  const LoadingDataState({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Success state
class SuccessDataState<T> extends BaseState with SuccessState<T> {
  @override
  final T? data;
  @override
  final String? successMessage;

  const SuccessDataState({this.data, this.successMessage});

  @override
  List<Object?> get props => [data, successMessage];
}

/// Error state
class ErrorDataState extends BaseState with ErrorState {
  @override
  final Failure failure;
  @override
  final String? errorMessage;

  const ErrorDataState(this.failure, {this.errorMessage});

  @override
  List<Object?> get props => [failure, errorMessage];
}
