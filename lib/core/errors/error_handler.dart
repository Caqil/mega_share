import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../constants/connection_constants.dart';
import '../services/logger_service.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Global error handler for the application
class ErrorHandler {
  static final LoggerService _logger = LoggerService.instance;

  /// Converts exceptions to failures
  static Failure handleException(Exception exception) {
    _logger.error('Exception occurred: $exception');

    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    } else if (exception is DioException) {
      return _mapDioExceptionToFailure(exception);
    } else if (exception is SocketException) {
      return _mapSocketExceptionToFailure(exception);
    } else if (exception is FileSystemException) {
      return _mapFileSystemExceptionToFailure(exception);
    } else if (exception is FormatException) {
      return ValidationFailure(
        'Invalid data format: ${exception.message}',
        code: 'FORMAT_ERROR',
      );
    } else {
      return _mapGenericExceptionToFailure(exception);
    }
  }

  /// Maps app-specific exceptions to failures
  static Failure _mapAppExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        final serverEx = exception as ServerException;
        return ServerFailure(
          serverEx.message,
          statusCode: serverEx.statusCode,
          code: serverEx.code,
        );

      case NetworkException:
        return NetworkFailure(exception.message, code: exception.code);

      case FileSystemException:
        final fileEx = exception as FileSystemException;
        return FileSystemFailure(
          fileEx.message,
          filePath: fileEx.filePath,
          code: fileEx.code,
        );

      case PermissionException:
        final permEx = exception as PermissionException;
        return PermissionFailure(
          permEx.message,
          permEx.permissionType,
          code: permEx.code,
        );

      case DiscoveryException:
        return DiscoveryFailure(exception.message, code: exception.code);

      case ConnectionException:
        final connEx = exception as ConnectionException;
        return ConnectionFailure(
          connEx.message,
          endpointId: connEx.endpointId,
          code: connEx.code,
        );

      case TransferException:
        final transferEx = exception as TransferException;
        return TransferFailure(
          transferEx.message,
          transferId: transferEx.transferId,
          fileName: transferEx.fileName,
          code: transferEx.code,
        );

      case AuthenticationException:
        return AuthenticationFailure(exception.message, code: exception.code);

      case StorageException:
        final storageEx = exception as StorageException;
        return StorageFailure(
          storageEx.message,
          availableBytes: storageEx.availableBytes,
          requiredBytes: storageEx.requiredBytes,
          code: storageEx.code,
        );

      case ValidationException:
        final validEx = exception as ValidationException;
        return ValidationFailure(
          validEx.message,
          fieldErrors: validEx.fieldErrors,
          code: validEx.code,
        );

      case CacheException:
        return CacheFailure(exception.message, code: exception.code);

      case TimeoutException:
        final timeoutEx = exception as TimeoutException;
        return TimeoutFailure(
          timeoutEx.message,
          timeoutEx.timeout,
          code: timeoutEx.code,
        );

      default:
        return ValidationFailure(
          exception.message,
          code: exception.code ?? 'UNKNOWN_APP_ERROR',
        );
    }
  }

  /// Maps Dio exceptions to failures
  static Failure _mapDioExceptionToFailure(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          'Request timeout occurred',
          Duration(seconds: AppConstants.requestTimeoutSeconds),
          code: 'NETWORK_TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        return ServerFailure(
          _getServerErrorMessage(statusCode),
          statusCode: statusCode,
          code: 'SERVER_ERROR',
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Connection error: ${exception.message}',
          code: 'CONNECTION_ERROR',
        );

      case DioExceptionType.cancel:
        return NetworkFailure(
          'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      default:
        return NetworkFailure(
          'Network error: ${exception.message}',
          code: 'NETWORK_ERROR',
        );
    }
  }

  /// Maps socket exceptions to failures
  static Failure _mapSocketExceptionToFailure(SocketException exception) {
    return NetworkFailure(
      'Network connection failed: ${exception.message}',
      code: 'SOCKET_ERROR',
    );
  }

  /// Maps file system exceptions to failures
  static Failure _mapFileSystemExceptionToFailure(
    FileSystemException exception,
  ) {
    return FileSystemFailure(
      'File system error: ${exception.message}',
      filePath: exception.filePath,
      code: 'FILE_SYSTEM_ERROR',
    );
  }

  /// Maps generic exceptions to failures
  static Failure _mapGenericExceptionToFailure(Exception exception) {
    return ValidationFailure(
      'An unexpected error occurred: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Gets appropriate server error message based on status code
  static String _getServerErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Server error occurred. Please try again later.';
    }
  }

  /// Gets user-friendly error message from failure
  static String getUserFriendlyMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return AppConstants.noInternetMessage;

      case PermissionFailure:
        return AppConstants.permissionDeniedMessage;

      case ConnectionFailure:
        return AppConstants.deviceNotFoundMessage;

      case TransferFailure:
        return AppConstants.transferFailedMessage;

      case StorageFailure:
        return 'Insufficient storage space available.';

      case TimeoutFailure:
        return 'Operation timed out. Please try again.';

      case ValidationFailure:
        return failure.message;

      default:
        return AppConstants.genericErrorMessage;
    }
  }

  /// Gets error code for analytics/logging
  static String getErrorCode(Failure failure) {
    return failure.code ?? 'UNKNOWN';
  }

  /// Determines if error is retryable
  static bool isRetryable(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
      case TimeoutFailure:
      case ServerFailure:
        return true;

      case PermissionFailure:
      case ValidationFailure:
      case AuthenticationFailure:
        return false;

      default:
        return false;
    }
  }

  /// Gets retry delay for retryable errors
  static Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff with jitter
    final baseDelay = AppConstants.retryDelay.inMilliseconds;
    final delay = baseDelay * (attemptNumber * attemptNumber);
    final jitter = (delay * 0.1).round();

    return Duration(milliseconds: delay + jitter);
  }
}
