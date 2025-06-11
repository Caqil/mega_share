import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/file_management_repository_impl.dart';

/// Parameters for delete file use case
class DeleteFileParams {
  final String filePath;

  const DeleteFileParams({required this.filePath});
}

/// Delete file use case
class DeleteFileUseCase implements UseCase<void, DeleteFileParams> {
  final FileManagementRepository _repository;

  DeleteFileUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteFileParams params) async {
    return await _repository.deleteFile(params.filePath);
  }
}
