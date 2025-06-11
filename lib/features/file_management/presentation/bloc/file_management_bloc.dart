

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/entities/storage_info_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../../domain/usecases/get_storage_info_usecase.dart';
import '../../domain/usecases/get_files_usecase.dart';
import '../../domain/usecases/get_folders_usecase.dart';
import '../../domain/usecases/create_folder_usecase.dart';
import '../../domain/usecases/delete_file_usecase.dart';
import '../../domain/usecases/manage_file_usecase.dart';
import '../../domain/usecases/request_permissions_usecase.dart';
import 'file_management_event.dart';
import 'file_management_state.dart';

class FileManagementBloc extends Bloc<FileManagementEvent, FileManagementState> {
  final GetStorageInfoUseCase _getStorageInfoUseCase;
  final GetFilesUseCase _getFilesUseCase;
  final GetFoldersUseCase _getFoldersUseCase;
  final CreateFolderUseCase _createFolderUseCase;
  final DeleteFileUseCase _deleteFileUseCase;
  final ManageFileUseCase _manageFileUseCase;
  final RequestPermissionsUseCase _requestPermissionsUseCase;

  StreamSubscription<StorageInfoEntity>? _storageInfoSubscription;
  Timer? _refreshTimer;

  FileManagementBloc({
    required GetStorageInfoUseCase getStorageInfoUseCase,
    required GetFilesUseCase getFilesUseCase,
    required GetFoldersUseCase getFoldersUseCase,
    required CreateFolderUseCase createFolderUseCase,
    required DeleteFileUseCase deleteFileUseCase,
    required ManageFileUseCase manageFileUseCase,
    required RequestPermissionsUseCase requestPermissionsUseCase,
  })  : _getStorageInfoUseCase = getStorageInfoUseCase,
        _getFilesUseCase = getFilesUseCase,
        _getFoldersUseCase = getFoldersUseCase,
        _createFolderUseCase = createFolderUseCase,
        _deleteFileUseCase = deleteFileUseCase,
        _manageFileUseCase = manageFileUseCase,
        _requestPermissionsUseCase = requestPermissionsUseCase,
        super(const FileManagementState()) {
    
    on<LoadStorageInfo>(_onLoadStorageInfo);
    on<RefreshStorageInfo>(_onRefreshStorageInfo);
    on<NavigateToPath>(_onNavigateToPath);
    on<NavigateBack>(_onNavigateBack);
    on<NavigateToRoot>(_onNavigateToRoot);
    on<LoadFiles>(_onLoadFiles);
    on<LoadFilesByType>(_onLoadFilesByType);
    on<LoadRecentFiles>(_onLoadRecentFiles);
    on<LoadFavoriteFiles>(_onLoadFavoriteFiles);
    on<LoadLargeFiles>(_onLoadLargeFiles);
    on<SearchFiles>(_onSearchFiles);
    on<LoadFolders>(_onLoadFolders);
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<RenameFolder>(_onRenameFolder);
    on<DeleteFile>(_onDeleteFile);
    on<RenameFile>(_onRenameFile);
    on<CopyFile>(_onCopyFile);
    on<MoveFile>(_onMoveFile);
    on<SelectFile>(_onSelectFile);
    on<UnselectFile>(_onUnselectFile);
    on<SelectAllFiles>(_onSelectAllFiles);
    on<ClearSelection>(_onClearSelection);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<AddTag>(_onAddTag);
    on<RemoveTag>(_onRemoveTag);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
    on<ChangeSortOrder>(_onChangeSortOrder);
    on<ChangeViewMode>(_onChangeViewMode);
    on<ToggleShowHidden>(_onToggleShowHidden);
    on<RequestPermissions>(_onRequestPermissions);
    on<CheckPermissions>(_onCheckPermissions);

    // Start storage info stream
    _startStorageInfoStream();
  }

  void _startStorageInfoStream() {
    _storageInfoSubscription?.cancel();
    _storageInfoSubscription = _getStorageInfoUseCase.getStream().listen(
      (storageInfo) {
        emit(state.copyWith(storageInfo: storageInfo));
      },
      onError: (error) {
        emit(state.copyWith(
          errorMessage: 'Storage info stream error: $error',
        ));
      },
    );
  }

  Future<void> _onLoadStorageInfo(
    LoadStorageInfo event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final storageInfo = await _getStorageInfoUseCase();
      
      emit(state.copyWith(
        status: FileManagementStatus.loaded,
        storageInfo: storageInfo,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FileManagementStatus.error,
        errorMessage: 'Failed to load storage info: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onRefreshStorageInfo(
    RefreshStorageInfo event,
    Emitter<FileManagementState> emit,
  ) async {
    add(const LoadStorageInfo());
  }

  Future<void> _onNavigateToPath(
    NavigateToPath event,
    Emitter<FileManagementState> emit,
  ) async {
    final newHistory = List<String>.from(state.navigationHistory);
    if (state.currentPath != event.path) {
      newHistory.add(state.currentPath);
    }
    
    emit(state.copyWith(
      currentPath: event.path,
      navigationHistory: newHistory,
      selectedFiles: {},
    ));
    
    // Load files and folders for the new path
    add(LoadFiles(path: event.path, refresh: true));
    add(LoadFolders(path: event.path));
  }

  Future<void> _onNavigateBack(
    NavigateBack event,
    Emitter<FileManagementState> emit,
  ) async {
    if (state.canNavigateBack) {
      final newHistory = List<String>.from(state.navigationHistory);
      final previousPath = newHistory.removeLast();
      
      emit(state.copyWith(
        currentPath: previousPath,
        navigationHistory: newHistory,
        selectedFiles: {},
      ));
      
      // Load files and folders for the previous path
      add(LoadFiles(path: previousPath, refresh: true));
      add(LoadFolders(path: previousPath));
    }
  }

  Future<void> _onNavigateToRoot(
    NavigateToRoot event,
    Emitter<FileManagementState> emit,
  ) async {
    const rootPath = '/storage/emulated/0';
    
    emit(state.copyWith(
      currentPath: rootPath,
      navigationHistory: [],
      selectedFiles: {},
    ));
    
    // Load files and folders for the root path
    add(const LoadFiles(path: rootPath, refresh: true));
    add(const LoadFolders(path: rootPath));
  }

  Future<void> _onLoadFiles(
    LoadFiles event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      if (!event.refresh) {
        emit(state.copyWith(isLoading: true));
      }
      
      final path = event.path ?? state.currentPath;
      
      // Check cache first
      if (!event.refresh && state.cachedFiles.containsKey(path)) {
        emit(state.copyWith(
          files: state.cachedFiles[path]!,
          isLoading: false,
        ));
        return;
      }
      
      final files = await _getFilesUseCase(GetFilesParams(
        path: path,
        filter: event.filter ?? state.currentFilter,
        sortBy: event.sortBy ?? state.sortBy,
        sortOrder: event.sortOrder ?? state.sortOrder,
      ));
      
      // Update cache
      final newCache = Map<String, List<FileEntity>>.from(state.cachedFiles);
      newCache[path] = files;
      
      emit(state.copyWith(
        status: FileManagementStatus.loaded,
        files: files,
        cachedFiles: newCache,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FileManagementStatus.error,
        errorMessage: 'Failed to load files: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadFilesByType(
    LoadFilesByType event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final files = await _getFilesUseCase.getByType(
        type: event.type,
        path: event.path,
        limit: event.limit,
      );
      
      emit(state.copyWith(
        files: files,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load files by type: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadRecentFiles(
    LoadRecentFiles event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final files = await _getFilesUseCase.getRecent(
        limit: event.limit,
        types: event.types,
      );
      
      emit(state.copyWith(
        files: files,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load recent files: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadFavoriteFiles(
    LoadFavoriteFiles event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final files = await _getFilesUseCase.getFavorites(
        types: event.types,
      );
      
      emit(state.copyWith(
        files: files,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load favorite files: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onLoadLargeFiles(
    LoadLargeFiles event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final files = await _getFilesUseCase.getLarge(
        limit: event.limit,
        minSize: event.minSize,
      );
      
      emit(state.copyWith(
        files: files,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load large files: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSearchFiles(
    SearchFiles event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isSearching: true,
        searchQuery: event.query,
      ));
      
      final files = await _getFilesUseCase.search(
        query: event.query,
        path: event.path ?? state.currentPath,
        types: event.types,
        limit: event.limit,
      );
      
      emit(state.copyWith(
        searchResults: files,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to search files: $e',
        isSearching: false,
      ));
    }
  }

  Future<void> _onLoadFolders(
    LoadFolders event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final path = event.path ?? state.currentPath;
      
      // Check cache first
      if (state.cachedFolders.containsKey(path)) {
        emit(state.copyWith(
          folders: state.cachedFolders[path]!,
        ));
        return;
      }
      
      final folders = await _getFoldersUseCase(GetFoldersParams(
        path: path,
        includeHidden: event.includeHidden || state.showHidden,
      ));
      
      // Update cache
      final newCache = Map<String, List<FolderEntity>>.from(state.cachedFolders);
      newCache[path] = folders;
      
      emit(state.copyWith(
        folders: folders,
        cachedFolders: newCache,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load folders: $e',
      ));
    }
  }

  Future<void> _onCreateFolder(
    CreateFolder event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _createFolderUseCase(CreateFolderParams(
        parentPath: event.parentPath,
        name: event.name,
      ));
      
      // Refresh the current directory
      add(LoadFolders(path: event.parentPath));
      
      // Clear cache for this path
      final newCache = Map<String, List<FolderEntity>>.from(state.cachedFolders);
      newCache.remove(event.parentPath);
      
      emit(state.copyWith(cachedFolders: newCache));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to create folder: $e',
      ));
    }
  }

  Future<void> _onDeleteFolder(
    DeleteFolder event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _deleteFileUseCase.deleteFolder(
        path: event.path,
        recursive: event.recursive,
      );
      
      // Refresh the current directory
      add(LoadFolders(path: state.currentPath));
      
      // Clear all caches since folder structure changed
      emit(state.copyWith(
        cachedFiles: {},
        cachedFolders: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete folder: $e',
      ));
    }
  }

  Future<void> _onRenameFolder(
    RenameFolder event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.renameFolder(
        path: event.path,
        newName: event.newName,
      );
      
      // Refresh the current directory
      add(LoadFolders(path: state.currentPath));
      
      // Clear cache
      emit(state.copyWith(
        cachedFolders: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to rename folder: $e',
      ));
    }
  }

  Future<void> _onDeleteFile(
    DeleteFile event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _deleteFileUseCase(DeleteFileParams(
        filePath: event.filePath,
        filePaths: event.filePaths,
      ));
      
      // Refresh the current directory
      add(LoadFiles(path: state.currentPath, refresh: true));
      
      // Clear selection
      emit(state.copyWith(selectedFiles: {}));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete file(s): $e',
      ));
    }
  }

  Future<void> _onRenameFile(
    RenameFile event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.renameFile(RenameFileParams(
        path: event.path,
        newName: event.newName,
      ));
      
      // Refresh the current directory
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to rename file: $e',
      ));
    }
  }

  Future<void> _onCopyFile(
    CopyFile event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.copyFile(CopyFileParams(
        sourcePath: event.sourcePath,
        destinationPath: event.destinationPath,
      ));
      
      // Refresh the current directory
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to copy file: $e',
      ));
    }
  }

  Future<void> _onMoveFile(
    MoveFile event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.moveFile(MoveFileParams(
        sourcePath: event.sourcePath,
        destinationPath: event.destinationPath,
      ));
      
      // Refresh the current directory
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to move file: $e',
      ));
    }
  }

  void _onSelectFile(
    SelectFile event,
    Emitter<FileManagementState> emit,
  ) {
    final newSelection = Set<String>.from(state.selectedFiles);
    newSelection.add(event.path);
    
    emit(state.copyWith(selectedFiles: newSelection));
  }

  void _onUnselectFile(
    UnselectFile event,
    Emitter<FileManagementState> emit,
  ) {
    final newSelection = Set<String>.from(state.selectedFiles);
    newSelection.remove(event.path);
    
    emit(state.copyWith(selectedFiles: newSelection));
  }

  void _onSelectAllFiles(
    SelectAllFiles event,
    Emitter<FileManagementState> emit,
  ) {
    final allPaths = state.files.map((f) => f.path).toSet();
    emit(state.copyWith(selectedFiles: allPaths));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(selectedFiles: {}));
  }

  void _onToggleFileSelection(
    ToggleFileSelection event,
    Emitter<FileManagementState> emit,
  ) {
    final newSelection = Set<String>.from(state.selectedFiles);
    
    if (newSelection.contains(event.path)) {
      newSelection.remove(event.path);
    } else {
      newSelection.add(event.path);
    }
    
    emit(state.copyWith(selectedFiles: newSelection));
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.addToFavorites(event.path);
      
      // Refresh current files to show updated favorite status
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add to favorites: $e',
      ));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.removeFromFavorites(event.path);
      
      // Refresh current files to show updated favorite status
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to remove from favorites: $e',
      ));
    }
  }

  Future<void> _onAddTag(
    AddTag event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.addTag(event.path, event.tag);
      
      // Refresh current files to show updated tags
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add tag: $e',
      ));
    }
  }

  Future<void> _onRemoveTag(
    RemoveTag event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      await _manageFileUseCase.removeTag(event.path, event.tag);
      
      // Refresh current files to show updated tags
      add(LoadFiles(path: state.currentPath, refresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to remove tag: $e',
      ));
    }
  }

  void _onApplyFilter(
    ApplyFilter event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(currentFilter: event.filter));
    
    // Reload files with the new filter
    add(LoadFiles(refresh: true));
  }

  void _onClearFilter(
    ClearFilter event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(currentFilter: null));
    
    // Reload files without filter
    add(LoadFiles(refresh: true));
  }

  void _onChangeSortOrder(
    ChangeSortOrder event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    ));
    
    // Reload files with new sort order
    add(LoadFiles(refresh: true));
  }

  void _onChangeViewMode(
    ChangeViewMode event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onToggleShowHidden(
    ToggleShowHidden event,
    Emitter<FileManagementState> emit,
  ) {
    emit(state.copyWith(showHidden: !state.showHidden));
    
    // Reload files and folders to apply hidden file visibility
    add(LoadFiles(refresh: true));
    add(LoadFolders());
  }

  Future<void> _onRequestPermissions(
    RequestPermissions event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final granted = await _requestPermissionsUseCase();
      
      if (granted) {
        final hasRead = await _requestPermissionsUseCase.hasReadPermission();
        final hasWrite = await _requestPermissionsUseCase.hasWritePermission();
        
        emit(state.copyWith(
          hasReadPermission: hasRead,
          hasWritePermission: hasWrite,
        ));
        
        // Load initial data if permissions were granted
        add(const LoadStorageInfo());
        add(LoadFiles(refresh: true));
        add(LoadFolders());
      } else {
        emit(state.copyWith(
          errorMessage: 'Storage permissions not granted',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to request permissions: $e',
      ));
    }
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<FileManagementState> emit,
  ) async {
    try {
      final hasRead = await _requestPermissionsUseCase.hasReadPermission();
      final hasWrite = await _requestPermissionsUseCase.hasWritePermission();
      
      emit(state.copyWith(
        hasReadPermission: hasRead,
        hasWritePermission: hasWrite,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to check permissions: $e',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _storageInfoSubscription?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}