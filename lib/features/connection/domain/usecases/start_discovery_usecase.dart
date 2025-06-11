import '../../../../core/constants/connection_constants.dart';
import '../entities/connection_entity.dart';
import '../repositories/connection_repository.dart';

class StartDiscoveryParams {
  final List<ConnectionType> connectionTypes;
  final bool enableAdvertising;
  final Duration? timeout;

  const StartDiscoveryParams({
    this.connectionTypes = const [
      ConnectionType.wifiDirect,
      ConnectionType.bluetooth,
      ConnectionType.wifiHotspot,
    ],
    this.enableAdvertising = true,
    this.timeout,
  });
}

class StartDiscoveryUseCase {
  final ConnectionRepository _repository;

  StartDiscoveryUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(StartDiscoveryParams params) async {
    try {
      // Check permissions
      final hasPermissions = await _repository.hasRequiredPermissions();
      if (!hasPermissions) {
        final permissionsGranted = await _repository.requestPermissions();
        if (!permissionsGranted) {
          throw Exception('Required permissions not granted');
        }
      }

      // Start discovery
      await _repository.startDiscovery(types: params.connectionTypes);

      // Start advertising if enabled
      if (params.enableAdvertising) {
        await _repository.startAdvertising(types: params.connectionTypes);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
