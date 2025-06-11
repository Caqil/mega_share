import 'dart:async';

import '../../../../core/constants/connection_constants.dart';
import '../entities/connection_entity.dart';
import '../repositories/connection_repository.dart';

class ConnectToDeviceParams {
  final String endpointId;
  final ConnectionType? preferredType;
  final bool requireAuthentication;
  final Duration timeout;

  const ConnectToDeviceParams({
    required this.endpointId,
    this.preferredType,
    this.requireAuthentication = true,
    this.timeout = const Duration(seconds: 30),
  });
}

class ConnectToDeviceUseCase {
  final ConnectionRepository _repository;

  ConnectToDeviceUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(ConnectToDeviceParams params) async {
    try {
      // Check if we have required permissions
      final hasPermissions = await _repository.hasRequiredPermissions();
      if (!hasPermissions) {
        final permissionsGranted = await _repository.requestPermissions();
        if (!permissionsGranted) {
          throw Exception('Required permissions not granted');
        }
      }

      // Check current connection info
      final connectionInfo = await _repository.getConnectionInfo();
      if (!connectionInfo.canAcceptConnections) {
        throw Exception('Maximum connections reached');
      }

      // Check if already connected to this device
      final existingConnection = await _repository.getConnection(
        params.endpointId,
      );
      if (existingConnection != null && existingConnection.isActive) {
        return true; // Already connected
      }

      // Start connection
      final success = await _repository.connectToDevice(
        params.endpointId,
        preferredType: params.preferredType,
      );

      if (!success) {
        throw Exception('Failed to connect to device');
      }

      // Wait for connection to be established
      final connectionStream = _repository.getConnectionStream(
        params.endpointId,
      );
      final completer = Completer<bool>();
      late StreamSubscription subscription;

      subscription = connectionStream.listen(
        (connection) {
          if (connection.status == ConnectionStatus.connected ||
              connection.status == ConnectionStatus.authenticated) {
            subscription.cancel();
            completer.complete(true);
          } else if (connection.status == ConnectionStatus.failed ||
              connection.status == ConnectionStatus.rejected) {
            subscription.cancel();
            completer.complete(false);
          }
        },
        onError: (error) {
          subscription.cancel();
          completer.completeError(error);
        },
      );

      // Set timeout
      Timer(params.timeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      return false;
    }
  }
}
