import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/folder_entity.dart';
import '../repositories/file_management_repository.dart';

/// Parameters for create folder use case
class CreateFolderParams {
  final String parentPath;
  final String folderName;

  const CreateFolderParams({
    required this.parentPath,
    required this.folderName,
  });
}

/// Create folder use case
class CreateFolderUseCase implements UseCase<FolderEntity, CreateFolderParams> {
  final FileManagementRepository _repository;

  CreateFolderUseCase(this._repository);

  @override
  Future<Either<Failure, FolderEntity>> call(CreateFolderParams params) async {
    return await _repository.createFolder(params.parentPath, params.folderName);
  }
}
