import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/file_system_datasource.dart';
import '../../data/repositories/file_management_repository_impl.dart';
import '../entities/folder_entity.dart';

/// Parameters for get folders use case
class GetFoldersParams {
  final String directoryPath;
  final bool includeHidden;
  final String? searchQuery;
  final FileSortOption sortBy;
  final FileSortOrder sortOrder;

  const GetFoldersParams({
    required this.directoryPath,
    this.includeHidden = false,
    this.searchQuery,
    this.sortBy = FileSortOption.name,
    this.sortOrder = FileSortOrder.ascending,
  });
}

/// Get folders use case
class GetFoldersUseCase
    implements UseCase<List<FolderEntity>, GetFoldersParams> {
  final FileManagementRepository _repository;

  GetFoldersUseCase(this._repository);

  @override
  Future<Either<Failure, List<FolderEntity>>> call(
    GetFoldersParams params,
  ) async {
    return await _repository.getFolders(
      params.directoryPath,
      includeHidden: params.includeHidden,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}
