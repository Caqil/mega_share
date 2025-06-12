import 'package:dartz/dartz.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/device_discovery_repository.dart';

/// Parameters for start discovery use case
class StartDiscoveryParams {
  final ConnectionType? method;
  final Duration? timeout;

  const StartDiscoveryParams({this.method, this.timeout});
}

/// Start discovery use case
class StartDiscoveryUseCase implements UseCase<void, StartDiscoveryParams> {
  final DeviceDiscoveryRepository _repository;

  StartDiscoveryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(StartDiscoveryParams params) async {
    return await _repository.startDiscovery(
      method: params.method,
      timeout: params.timeout,
    );
  }
}
