import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/file_management_repository_impl.dart';
import '../entities/storage_info_entity.dart';

/// Get storage info use case
class GetStorageInfoUseCase
    implements UseCase<List<StorageInfoEntity>, NoParams> {
  final FileManagementRepository _repository;

  GetStorageInfoUseCase(this._repository);

  @override
  Future<Either<Failure, List<StorageInfoEntity>>> call(NoParams params) async {
    return await _repository.getStorageInfo();
  }
}
