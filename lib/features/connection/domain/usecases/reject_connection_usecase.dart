import '../repositories/connection_repository.dart';

class RejectConnectionParams {
  final String endpointId;
  final String? reason;

  const RejectConnectionParams({required this.endpointId, this.reason});
}

class RejectConnectionUseCase {
  final ConnectionRepository _repository;

  RejectConnectionUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(RejectConnectionParams params) async {
    try {
      // Check if connection exists
      final connection = await _repository.getConnection(params.endpointId);
      if (connection == null) {
        return true; // Already rejected or doesn't exist
      }

      // Reject the connection
      final success = await _repository.rejectConnection(params.endpointId);
      if (!success) {
        throw Exception('Failed to reject connection');
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
