import 'package:equatable/equatable.dart';

/// Base model class for all data models
abstract class BaseModel extends Equatable {
  const BaseModel();

  /// Convert model to JSON
  Map<String, dynamic> toJson();

  /// Create model from JSON
  /// This should be implemented by subclasses
  // BaseModel fromJson(Map<String, dynamic> json);

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

/// Base entity class for domain models
abstract class BaseEntity extends Equatable {
  const BaseEntity();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

/// Mixin for models with timestamps
mixin TimestampMixin {
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Check if the model was created today
  bool get isCreatedToday {
    final now = DateTime.now();
    final created = createdAt;
    return now.year == created.year &&
        now.month == created.month &&
        now.day == created.day;
  }

  /// Check if the model was updated recently (within last hour)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 1;
  }

  /// Get age of the model
  Duration get age => DateTime.now().difference(createdAt);

  /// Get time since last update
  Duration get timeSinceUpdate => DateTime.now().difference(updatedAt);
}

/// Mixin for models with unique identifiers
mixin IdentifiableMixin {
  String get id;

  /// Check if this model has the same ID as another
  bool hasSameId(IdentifiableMixin other) => id == other.id;

  /// Check if ID is valid (not empty)
  bool get hasValidId => id.isNotEmpty;
}

/// Base result class for operations
sealed class Result<T> extends Equatable {
  const Result();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Get error if failure, null otherwise
  String? get errorOrNull => isFailure ? (this as Failure<T>).message : null;

  /// Transform the data if success
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success<T> success => Success(transform(success.data)),
      Failure<T> failure => Failure(failure.message, failure.code),
    };
  }

  /// Handle both success and failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) failure,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.message, f.code),
    };
  }
}

/// Success result
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Failure result
class Failure<T> extends Result<T> {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}
