import 'package:equatable/equatable.dart';

/// Base event class for all BLoC events
abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

/// Common events that can be used across different BLoCs
class LoadEvent extends BaseEvent {
  final bool forceRefresh;

  const LoadEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshEvent extends BaseEvent {
  const RefreshEvent();
}

class ResetEvent extends BaseEvent {
  const ResetEvent();
}

class RetryEvent extends BaseEvent {
  const RetryEvent();
}
