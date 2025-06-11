import 'package:equatable/equatable.dart';

/// Base failure class for all app failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server/API related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode, super.code});

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() =>
      'ServerFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Network/Connectivity related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// File system related failures
class FileSystemFailure extends Failure {
  final String? filePath;

  const FileSystemFailure(super.message, {this.filePath, super.code});

  @override
  List<Object?> get props => [message, code, filePath];

  @override
  String toString() =>
      'FileSystemFailure: $message${filePath != null ? ' (Path: $filePath)' : ''}';
}

/// Permission related failures
class PermissionFailure extends Failure {
  final String permissionType;

  const PermissionFailure(super.message, this.permissionType, {super.code});

  @override
  List<Object?> get props => [message, code, permissionType];

  @override
  String toString() =>
      'PermissionFailure: $message (Permission: $permissionType)';
}

/// Device discovery related failures
class DiscoveryFailure extends Failure {
  const DiscoveryFailure(super.message, {super.code});
}

/// Connection related failures
class ConnectionFailure extends Failure {
  final String? endpointId;

  const ConnectionFailure(super.message, {this.endpointId, super.code});

  @override
  List<Object?> get props => [message, code, endpointId];

  @override
  String toString() =>
      'ConnectionFailure: $message${endpointId != null ? ' (Endpoint: $endpointId)' : ''}';
}

/// Transfer related failures
class TransferFailure extends Failure {
  final String? transferId;
  final String? fileName;

  const TransferFailure(
    super.message, {
    this.transferId,
    this.fileName,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, transferId, fileName];

  @override
  String toString() =>
      'TransferFailure: $message${fileName != null ? ' (File: $fileName)' : ''}';
}

/// Authentication related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

/// Storage related failures
class StorageFailure extends Failure {
  final int? availableBytes;
  final int? requiredBytes;

  const StorageFailure(
    super.message, {
    this.availableBytes,
    this.requiredBytes,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, availableBytes, requiredBytes];

  @override
  String toString() {
    final extra = availableBytes != null && requiredBytes != null
        ? ' (Available: ${availableBytes! ~/ (1024 * 1024)}MB, Required: ${requiredBytes! ~/ (1024 * 1024)}MB)'
        : '';
    return 'StorageFailure: $message$extra';
  }
}

/// Validation related failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors, super.code});

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Timeout related failures
class TimeoutFailure extends Failure {
  final Duration timeout;

  const TimeoutFailure(super.message, this.timeout, {super.code});

  @override
  List<Object?> get props => [message, code, timeout];

  @override
  String toString() =>
      'TimeoutFailure: $message (Timeout: ${timeout.inSeconds}s)';
}
