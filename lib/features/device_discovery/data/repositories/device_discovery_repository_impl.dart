import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/discovery_result_entity.dart';
import '../../domain/repositories/device_discovery_repository.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/logger_service.dart';
import '../datasources/nearby_devices_datasource.dart';

/// Device discovery repository implementation
class DeviceDiscoveryRepositoryImpl implements DeviceDiscoveryRepository {
  final NearbyDevicesDataSource _dataSource;
  final LoggerService _logger = LoggerService();

  DeviceDiscoveryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> startDiscovery({
    ConnectionType? method,
    Duration? timeout,
  }) async {
    try {
      await _dataSource.startDiscovery(method: method, timeout: timeout);
      _logger.info('Discovery started successfully');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to start discovery: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> stopDiscovery() async {
    try {
      await _dataSource.stopDiscovery();
      _logger.info('Discovery stopped successfully');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to stop discovery: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
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
        timeout: timeout,
      );
      _logger.info('Advertising started successfully');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to start advertising: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> stopAdvertising() async {
    try {
      await _dataSource.stopAdvertising();
      _logger.info('Advertising stopped successfully');
      return const Right(null);
    } catch (e) {
      _logger.error('Failed to stop advertising: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Stream<Either<Failure, DiscoveryResultEntity>> get discoveredDevicesStream {
    return _dataSource.discoveredDevicesStream
        .map((result) {
          try {
            return Right(result.toEntity());
          } catch (e) {
            _logger.error('Error mapping discovery result: $e');
            final failure = ErrorHandler.handleException(e as Exception);
            return Left(failure);
          }
        })
        .handleError((error) {
          _logger.error('Error in discovery stream: $error');
          final failure = ErrorHandler.handleException(error as Exception);
          return Left(failure);
        });
  }

  @override
  bool get isDiscovering => _dataSource.isDiscovering;

  @override
  bool get isAdvertising => _dataSource.isAdvertising;

  @override
  Either<Failure, DiscoveryResultEntity?> getLastDiscoveryResult() {
    try {
      final result = _dataSource.lastDiscoveryResult?.toEntity();
      return Right(result);
    } catch (e) {
      _logger.error('Error getting last discovery result: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> clearDiscoveryCache() async {
    try {
      await _dataSource.clearDiscoveryCache();
      _logger.debug('Discovery cache cleared');
      return const Right(null);
    } catch (e) {
      _logger.error('Error clearing discovery cache: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }

  @override
  Either<Failure, List<DeviceEntity>> getCachedDevices() {
    try {
      final devices = _dataSource
          .getCachedDevices()
          .map((device) => device.toEntity())
          .toList();
      return Right(devices);
    } catch (e) {
      _logger.error('Error getting cached devices: $e');
      final failure = ErrorHandler.handleException(e as Exception);
      return Left(failure);
    }
  }
}
