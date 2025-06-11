import 'package:dartz/dartz.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/file_system_datasource.dart';
import '../../data/repositories/file_management_repository_impl.dart';
import '../entities/file_entity.dart';

/// Parameters for get files use case
class GetFilesParams {
  final String directoryPath;
  final bool includeHidden;
  final FileCategory? categoryFilter;
  final String? searchQuery;
  final FileSortOption sortBy;
  final FileSortOrder sortOrder;

  const GetFilesParams({
    required this.directoryPath,
    this.includeHidden = false,
    this.categoryFilter,
    this.searchQuery,
    this.sortBy = FileSortOption.name,
    this.sortOrder = FileSortOrder.ascending,
  });
}

/// Get files use case
class GetFilesUseCase implements UseCase<List<FileEntity>, GetFilesParams> {
  final FileManagementRepository _repository;

  GetFilesUseCase(this._repository);

  @override
  Future<Either<Failure, List<FileEntity>>> call(GetFilesParams params) async {
    return await _repository.getFiles(
      params.directoryPath,
      includeHidden: params.includeHidden,
      categoryFilter: params.categoryFilter,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}
