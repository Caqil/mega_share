import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/device_discovery_repository.dart';

/// Stop advertising use case
class StopAdvertisingUseCase implements UseCase<void, NoParams> {
  final DeviceDiscoveryRepository _repository;

  StopAdvertisingUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await _repository.stopAdvertising();
  }
}
