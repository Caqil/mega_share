import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/logger_service.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';
import 'base_event.dart';
import 'base_state.dart';

/// Base BLoC class with common functionality
abstract class BaseBloc<E extends BaseEvent, S extends BaseState>
    extends Bloc<E, S> {
  final LoggerService _logger = LoggerService.instance;

  BaseBloc(super.initialState) {
    // Log state changes
    on<E>((event, emit) async {
      _logger.debug('Event: ${event.runtimeType}', tag: runtimeType.toString());
      await handleEvent(event, emit);
    });

    // Listen to state changes for logging
    stream.listen((state) {
      _logger.debug('State: ${state.runtimeType}', tag: runtimeType.toString());
    });
  }

  /// Handle the event - to be implemented by subclasses
  Future<void> handleEvent(E event, Emitter<S> emit);

  /// Emit loading state
  void emitLoading(Emitter<S> emit, {String? message}) {
    if (state is! LoadingState) {
      final loadingState = createLoadingState(message);
      if (loadingState != null) {
        emit(loadingState);
      }
    }
  }

  /// Emit success state
  void emitSuccess(Emitter<S> emit, {dynamic data, String? message}) {
    final successState = createSuccessState(data: data, message: message);
    if (successState != null) {
      emit(successState);
    }
  }

  /// Emit error state
  void emitError(Emitter<S> emit, Failure failure, {String? message}) {
    _logger.error(
      'Error in ${runtimeType}: ${message ?? failure.message}',
      error: failure,
    );

    final errorState = createErrorState(
      failure,
      message: message ?? ErrorHandler.getUserFriendlyMessage(failure),
    );
    if (errorState != null) {
      emit(errorState);
    }
  }

  /// Handle exceptions and convert to failures
  Future<void> handleException(
    Emitter<S> emit,
    Exception exception, {
    String? message,
  }) async {
    final failure = ErrorHandler.handleException(exception);
    emitError(emit, failure, message: message);
  }

  /// Execute async operation with error handling
  Future<void> safeCall(
    Emitter<S> emit,
    Future<void> Function() operation, {
    String? loadingMessage,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        emitLoading(emit, message: loadingMessage);
      }
      await operation();
    } catch (e) {
      if (e is Exception) {
        await handleException(emit, e);
      } else {
        final failure = Failure('An unexpected error occurred: $e');
        emitError(emit, failure);
      }
    }
  }

  /// Create loading state - to be implemented by subclasses
  S? createLoadingState(String? message) => null;

  /// Create success state - to be implemented by subclasses
  S? createSuccessState({dynamic data, String? message}) => null;

  /// Create error state - to be implemented by subclasses
  S? createErrorState(Failure failure, {String? message}) => null;

  @override
  Future<void> close() {
    _logger.debug('Closing ${runtimeType}');
    return super.close();
  }
}
