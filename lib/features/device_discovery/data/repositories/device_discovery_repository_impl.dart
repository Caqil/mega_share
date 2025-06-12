import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/discovery_result_entity.dart';
import '../../domain/repositories/device_discovery_repository.dart';
import '../datasources/nearby_devices_datasource.dart';
import '../models/discovery_result_model.dart';

/// Device discovery repository implementation
class DeviceDiscoveryRepositoryImpl implements DeviceDiscoveryRepository {
  final NearbyDevicesDataSource _dataSource;

  // Cache management
  DiscoveryResultEntity? _lastDiscoveryResult;
  final StreamController<Either<Failure, DiscoveryResultEntity>>
  _discoveryController =
      StreamController<Either<Failure, DiscoveryResultEntity>>.broadcast();

  StreamSubscription<DiscoveryResultModel>? _discoverySubscription;

  DeviceDiscoveryRepositoryImpl({required NearbyDevicesDataSource dataSource})
    : _dataSource = dataSource {
    _initializeDiscoveryStream();
  }

  void _initializeDiscoveryStream() {
    _discoverySubscription = _dataSource.discoveryResultStream.listen(
      (discoveryResultModel) {
        final entity = discoveryResultModel.toEntity();
        _lastDiscoveryResult = entity;
        _discoveryController.add(Right(entity));
      },
      onError: (error) {
        Failure failure;
        if (error is DiscoveryException) {
          failure = DiscoveryFailure(error.message, code: error.code);
        } else if (error is PermissionException) {
          failure = PermissionFailure(
            error.message,
            error.permissionType,
            code: error.code,
          );
        } else if (error is NetworkException) {
          failure = NetworkFailure(error.message, code: error.code);
        } else if (error is TimeoutException) {
          failure = TimeoutFailure(
            error.message,
            error.timeout,
            code: error.code,
          );
        } else {
          failure = DiscoveryFailure(
            'Unknown discovery error: ${error.toString()}',
          );
        }
        _discoveryController.add(Left(failure));
      },
    );
  }

  @override
  Future<Either<Failure, void>> startDiscovery({
    ConnectionType? method,
    Duration? timeout,
  }) async {
    try {
      await _dataSource.startDiscovery(
        method: method ?? ConnectionType.nearbyConnections,
        timeout: timeout ?? const Duration(minutes: 5),
      );
      return const Right(null);
    } on DiscoveryException catch (e) {
      return Left(DiscoveryFailure(e.message, code: e.code));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message, e.permissionType, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message, e.timeout, code: e.code));
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to start discovery: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> stopDiscovery() async {
    try {
      await _dataSource.stopDiscovery();
      return const Right(null);
    } on DiscoveryException catch (e) {
      return Left(DiscoveryFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to stop discovery: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> startAdvertising({
    String? deviceName,
    Duration? timeout,
  }) async {
    try {
      await _dataSource.startAdvertising(
        deviceName: deviceName,
        timeout: timeout ?? const Duration(minutes: 10),
      );
      return const Right(null);
    } on DiscoveryException catch (e) {
      return Left(DiscoveryFailure(e.message, code: e.code));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message, e.permissionType, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(e.message, e.timeout, code: e.code));
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to start advertising: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> stopAdvertising() async {
    try {
      await _dataSource.stopAdvertising();
      return const Right(null);
    } on DiscoveryException catch (e) {
      return Left(DiscoveryFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to stop advertising: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, DiscoveryResultEntity>> get discoveredDevicesStream =>
      _discoveryController.stream;

  @override
  bool get isDiscovering => _dataSource.isDiscovering;

  @override
  bool get isAdvertising => _dataSource.isAdvertising;

  @override
  Either<Failure, DiscoveryResultEntity?> getLastDiscoveryResult() {
    try {
      return Right(_lastDiscoveryResult);
    } catch (e) {
      return Left(
        DiscoveryFailure(
          'Failed to get last discovery result: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearDiscoveryCache() async {
    try {
      await _dataSource.clearCache();
      _lastDiscoveryResult = null;
      return const Right(null);
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to clear discovery cache: ${e.toString()}'),
      );
    }
  }

  @override
  Either<Failure, List<DeviceEntity>> getCachedDevices() {
    try {
      final devices = _dataSource
          .getCachedDevices()
          .map((deviceModel) => deviceModel.toEntity())
          .toList();
      return Right(devices);
    } catch (e) {
      return Left(
        DiscoveryFailure('Failed to get cached devices: ${e.toString()}'),
      );
    }
  }

  void dispose() {
    _discoverySubscription?.cancel();
    _discoveryController.close();
  }
}
