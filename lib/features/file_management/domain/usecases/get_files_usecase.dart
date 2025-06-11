
import '../repositories/file_management_repository.dart';
import '../entities/file_entity.dart';

class GetFilesParams {
  final String path;
  final FileFilter? filter;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final int? limit;
  final int? offset;

  const GetFilesParams({
    required this.path,
    this.filter,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.ascending,
    this.limit,
    this.offset,
  });
}

class GetFilesUseCase {
  final FileManagementRepository _repository;

  GetFilesUseCase({required FileManagementRepository repository})
      : _repository = repository;

  Future<List<FileEntity>> call(GetFilesParams params) async {
    try {
      // Check permissions first
      final hasPermission = await _repository.hasReadPermission();
      if (!hasPermission) {
        final granted = await _repository.requestPermissions();
        if (!granted) {
          throw Exception('Storage permissions not granted');
        }
      }

      return await _repository.getFiles(
        path: params.path,
        filter: params.filter,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
        limit: params.limit,
        offset: params.offset,
      );
    } catch (e) {
      throw Exception('Failed to get files: $e');
    }
  }

  Future<List<FileEntity>> getByType({
    required FileType type,
    String? path,
    SortBy sortBy = SortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) async {
    try {
      return await _repository.getFilesByType(
        type: type,
        path: path,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to get files by type: $e');
    }
  }

  Future<List<FileEntity>> getRecent({
    int limit = 50,
    List<FileType>? types,
  }) async {
    try {
      return await _repository.getRecentFiles(
        limit: limit,
        types: types,
      );
    } catch (e) {
      throw Exception('Failed to get recent files: $e');
    }
  }

  Future<List<FileEntity>> getFavorites({
    List<FileType>? types,
  }) async {
    try {
      return await _repository.getFavoriteFiles(types: types);
    } catch (e) {
      throw Exception('Failed to get favorite files: $e');
    }
  }

  Future<List<FileEntity>> getLarge({
    int limit = 20,
    int? minSize,
  }) async {
    try {
      return await _repository.getLargeFiles(
        limit: limit,
        minSize: minSize,
      );
    } catch (e) {
      throw Exception('Failed to get large files: $e');
    }
  }

  Future<List<FileEntity>> search({
    required String query,
    String? path,
    List<FileType>? types,
    int? limit,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      return await _repository.searchFiles(
        query: query,
        path: path,
        types: types,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to search files: $e');
    }
  }
}
