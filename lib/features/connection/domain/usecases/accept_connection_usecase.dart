import '../entities/connection_entity.dart';
import '../repositories/connection_repository.dart';

class AcceptConnectionParams {
  final String endpointId;
  final bool requireAuthentication;

  const AcceptConnectionParams({
    required this.endpointId,
    this.requireAuthentication = true,
  });
}

class AcceptConnectionUseCase {
  final ConnectionRepository _repository;

  AcceptConnectionUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(AcceptConnectionParams params) async {
    try {
      // Check if connection exists and is in the right state
      final connection = await _repository.getConnection(params.endpointId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      if (connection.status != ConnectionStatus.connecting) {
        throw Exception('Connection is not in connecting state');
      }

      // Check connection capacity
      final connectionInfo = await _repository.getConnectionInfo();
      if (!connectionInfo.canAcceptConnections) {
        throw Exception('Maximum connections reached');
      }

      // Accept the connection
      final success = await _repository.acceptConnection(params.endpointId);
      if (!success) {
        throw Exception('Failed to accept connection');
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
