import '../repositories/connection_repository.dart';

class ConnectFromQRCodeParams {
  final String qrData;
  final Duration timeout;

  const ConnectFromQRCodeParams({
    required this.qrData,
    this.timeout = const Duration(seconds: 30),
  });
}

class ConnectFromQRCodeUseCase {
  final ConnectionRepository _repository;

  ConnectFromQRCodeUseCase({required ConnectionRepository repository})
    : _repository = repository;

  Future<bool> call(ConnectFromQRCodeParams params) async {
    try {
      // Check permissions
      final hasPermissions = await _repository.hasRequiredPermissions();
      if (!hasPermissions) {
        final permissionsGranted = await _repository.requestPermissions();
        if (!permissionsGranted) {
          throw Exception('Required permissions not granted');
        }
      }

      // Connect using QR code
      final success = await _repository.connectFromQRCode(params.qrData);
      if (!success) {
        throw Exception('Failed to connect from QR code');
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
