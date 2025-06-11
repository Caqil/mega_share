import 'package:equatable/equatable.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import 'file_management_event.dart';

enum FileManagementStatus { initial, loading, loaded, error }

class FileManagementState extends Equatable {
  final FileManagementStatus status;
  final StorageInfoEntity? storageInfo;
  final String currentPath;
  final List<String> navigationHistory;
  final List<FileEntity> files;
  final List<FolderEntity> folders;
  final Set<String> selectedFiles;
  final FileFilter? currentFilter;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final ViewMode viewMode;
  final bool showHidden;
  final bool hasReadPermission;
  final bool hasWritePermission;
  final String? errorMessage;
  final bool isLoading;
  final bool isSearching;
  final String? searchQuery;
  final List<FileEntity> searchResults;
  final Map<String, List<FileEntity>> cachedFiles;
  final Map<String, List<FolderEntity>> cachedFolders;

  const FileManagementState({
    this.status = FileManagementStatus.initial,
    this.storageInfo,
    this.currentPath = '/storage/emulated/0',
    this.navigationHistory = const [],
    this.files = const [],
    this.folders = const [],
    this.selectedFiles = const {},
    this.currentFilter,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.ascending,
    this.viewMode = ViewMode.list,
    this.showHidden = false,
    this.hasReadPermission = false,
    this.hasWritePermission = false,
    this.errorMessage,
    this.isLoading = false,
    this.isSearching = false,
    this.searchQuery,
    this.searchResults = const [],
    this.cachedFiles = const {},
    this.cachedFolders = const {},
  });

  FileManagementState copyWith({
    FileManagementStatus? status,
    StorageInfoEntity? storageInfo,
    String? currentPath,
    List<String>? navigationHistory,
    List<FileEntity>? files,
    List<FolderEntity>? folders,
    Set<String>? selectedFiles,
    FileFilter? currentFilter,
    SortBy? sortBy,
    SortOrder? sortOrder,
    ViewMode? viewMode,
    bool? showHidden,
    bool? hasReadPermission,
    bool? hasWritePermission,
    String? errorMessage,
    bool? isLoading,
    bool? isSearching,
    String? searchQuery,
    List<FileEntity>? searchResults,
    Map<String, List<FileEntity>>? cachedFiles,
    Map<String, List<FolderEntity>>? cachedFolders,
  }) {
    return FileManagementState(
      status: status ?? this.status,
      storageInfo: storageInfo ?? this.storageInfo,
      currentPath: currentPath ?? this.currentPath,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      files: files ?? this.files,
      folders: folders ?? this.folders,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      currentFilter: currentFilter ?? this.currentFilter,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      viewMode: viewMode ?? this.viewMode,
      showHidden: showHidden ?? this.showHidden,
      hasReadPermission: hasReadPermission ?? this.hasReadPermission,
      hasWritePermission: hasWritePermission ?? this.hasWritePermission,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      cachedFiles: cachedFiles ?? this.cachedFiles,
      cachedFolders: cachedFolders ?? this.cachedFolders,
    );
  }

  FileManagementState clearError() {
    return copyWith(errorMessage: null);
  }

  bool get canNavigateBack => navigationHistory.isNotEmpty;
  bool get hasSelection => selectedFiles.isNotEmpty;
  int get selectedCount => selectedFiles.length;
  bool Function(String path) get isFileSelected =>
      (String path) => selectedFiles.contains(path);
  bool get hasFilter => currentFilter != null;
  List<FileEntity> get allItems => [
    ...folders.map(
      (f) => FileEntity(
        id: f.id,
        name: f.name,
        path: f.path,
        extension: '',
        size: f.totalSize,
        dateCreated: f.dateCreated,
        dateModified: f.dateModified,
        dateAccessed: f.dateAccessed,
        type: FileType.unknown,
        source: f.source,
        mimeType: 'folder',
        isHidden: f.isHidden,
        isReadOnly: f.isReadOnly,
        isDirectory: true,
        metadata: f.metadata,
        parentPath: f.parentPath,
        isFavorite: f.isFavorite,
        accessCount: 0,
        tags: f.tags,
      ),
    ),
    ...files,
  ];

  @override
  List<Object?> get props => [
    status,
    storageInfo,
    currentPath,
    navigationHistory,
    files,
    folders,
    selectedFiles,
    currentFilter,
    sortBy,
    sortOrder,
    viewMode,
    showHidden,
    hasReadPermission,
    hasWritePermission,
    errorMessage,
    isLoading,
    isSearching,
    searchQuery,
    searchResults,
    cachedFiles,
    cachedFolders,
  ];
}
