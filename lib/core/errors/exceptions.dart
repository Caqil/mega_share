abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server/API related exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Network/Connectivity related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalException});
}

/// File system related exceptions
class FileSystemException extends AppException {
  final String? filePath;

  const FileSystemException(
    super.message, {
    this.filePath,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'FileSystemException: $message${filePath != null ? ' (Path: $filePath)' : ''}';
}

/// Permission related exceptions
class PermissionException extends AppException {
  final String permissionType;

  const PermissionException(
    super.message,
    this.permissionType, {
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'PermissionException: $message (Permission: $permissionType)';
}

/// Device discovery related exceptions
class DiscoveryException extends AppException {
  const DiscoveryException(
    super.message, {
    super.code,
    super.originalException,
  });
}

/// Connection related exceptions
class ConnectionException extends AppException {
  final String? endpointId;

  const ConnectionException(
    super.message, {
    this.endpointId,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'ConnectionException: $message${endpointId != null ? ' (Endpoint: $endpointId)' : ''}';
}

/// Transfer related exceptions
class TransferException extends AppException {
  final String? transferId;
  final String? fileName;

  const TransferException(
    super.message, {
    this.transferId,
    this.fileName,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'TransferException: $message${fileName != null ? ' (File: $fileName)' : ''}';
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.originalException,
  });
}

/// Storage related exceptions
class StorageException extends AppException {
  final int? availableBytes;
  final int? requiredBytes;

  const StorageException(
    super.message, {
    this.availableBytes,
    this.requiredBytes,
    super.code,
    super.originalException,
  });

  @override
  String toString() {
    final extra = availableBytes != null && requiredBytes != null
        ? ' (Available: ${availableBytes! ~/ (1024 * 1024)}MB, Required: ${requiredBytes! ~/ (1024 * 1024)}MB)'
        : '';
    return 'StorageException: $message$extra';
  }
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalException});
}

/// Timeout related exceptions
class TimeoutException extends AppException {
  final Duration timeout;

  const TimeoutException(
    super.message,
    this.timeout, {
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}
