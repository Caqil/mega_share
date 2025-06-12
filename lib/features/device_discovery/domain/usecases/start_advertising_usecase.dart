import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/device_discovery_repository.dart';

/// Parameters for start advertising use case
class StartAdvertisingParams {
  final String? deviceName;
  final Duration? timeout;

  const StartAdvertisingParams({this.deviceName, this.timeout});
}

/// Start advertising use case
class StartAdvertisingUseCase implements UseCase<void, StartAdvertisingParams> {
  final DeviceDiscoveryRepository _repository;

  StartAdvertisingUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(StartAdvertisingParams params) async {
    return await _repository.startAdvertising(
      deviceName: params.deviceName,
      timeout: params.timeout,
    );
  }
}
