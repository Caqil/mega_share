import '../repositories/file_management_repository.dart';
import '../entities/folder_entity.dart';

class GetFoldersParams {
  final String path;
  final bool includeHidden;
  final SortBy sortBy;
  final SortOrder sortOrder;

  const GetFoldersParams({
    required this.path,
    this.includeHidden = false,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.ascending,
  });
}

class GetFoldersUseCase {
  final FileManagementRepository _repository;

  GetFoldersUseCase({required FileManagementRepository repository})
    : _repository = repository;

  Future<List<FolderEntity>> call(GetFoldersParams params) async {
    try {
      // Check permissions first
      final hasPermission = await _repository.hasReadPermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage permissions not granted');
        }
      }

      return await _repository.getFolders(
        path: params.path,
        includeHidden: params.includeHidden,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
      );
    } catch (e) {
      throw Exception('Failed to get folders: $e');
    }
  }
}
