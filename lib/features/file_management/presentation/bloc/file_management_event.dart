// lib/features/file_management/presentation/bloc/file_management_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';

abstract class FileManagementEvent extends Equatable {
  const FileManagementEvent();

  @override
  List<Object?> get props => [];
}

// Storage Events
class LoadStorageInfo extends FileManagementEvent {
  const LoadStorageInfo();
}

class RefreshStorageInfo extends FileManagementEvent {
  const RefreshStorageInfo();
}

// Navigation Events
class NavigateToPath extends FileManagementEvent {
  final String path;

  const NavigateToPath({required this.path});

  @override
  List<Object?> get props => [path];
}

class NavigateBack extends FileManagementEvent {
  const NavigateBack();
}

class NavigateToRoot extends FileManagementEvent {
  const NavigateToRoot();
}

// File Events
class LoadFiles extends FileManagementEvent {
  final String? path;
  final FileFilter? filter;
  final SortBy? sortBy;
  final SortOrder? sortOrder;
  final bool refresh;

  const LoadFiles({
    this.path,
    this.filter,
    this.sortBy,
    this.sortOrder,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [path, filter, sortBy, sortOrder, refresh];
}

class LoadFilesByType extends FileManagementEvent {
  final FileType type;
  final String? path;
  final int? limit;

  const LoadFilesByType({required this.type, this.path, this.limit});

  @override
  List<Object?> get props => [type, path, limit];
}

class LoadRecentFiles extends FileManagementEvent {
  final int limit;
  final List<FileType>? types;

  const LoadRecentFiles({this.limit = 50, this.types});

  @override
  List<Object?> get props => [limit, types];
}

class LoadFavoriteFiles extends FileManagementEvent {
  final List<FileType>? types;

  const LoadFavoriteFiles({this.types});

  @override
  List<Object?> get props => [types];
}

class LoadLargeFiles extends FileManagementEvent {
  final int limit;
  final int? minSize;

  const LoadLargeFiles({this.limit = 20, this.minSize});

  @override
  List<Object?> get props => [limit, minSize];
}

class SearchFiles extends FileManagementEvent {
  final String query;
  final String? path;
  final List<FileType>? types;
  final int? limit;

  const SearchFiles({required this.query, this.path, this.types, this.limit});

  @override
  List<Object?> get props => [query, path, types, limit];
}

// Folder Events
class LoadFolders extends FileManagementEvent {
  final String? path;
  final bool includeHidden;

  const LoadFolders({this.path, this.includeHidden = false});

  @override
  List<Object?> get props => [path, includeHidden];
}

class CreateFolder extends FileManagementEvent {
  final String parentPath;
  final String name;

  const CreateFolder({required this.parentPath, required this.name});

  @override
  List<Object?> get props => [parentPath, name];
}

class DeleteFolder extends FileManagementEvent {
  final String path;
  final bool recursive;

  const DeleteFolder({required this.path, this.recursive = false});

  @override
  List<Object?> get props => [path, recursive];
}

class RenameFolder extends FileManagementEvent {
  final String path;
  final String newName;

  const RenameFolder({required this.path, required this.newName});

  @override
  List<Object?> get props => [path, newName];
}

// File Management Events
class DeleteFile extends FileManagementEvent {
  final String? filePath;
  final List<String>? filePaths;

  const DeleteFile({this.filePath, this.filePaths});

  @override
  List<Object?> get props => [filePath, filePaths];
}

class RenameFile extends FileManagementEvent {
  final String path;
  final String newName;

  const RenameFile({required this.path, required this.newName});

  @override
  List<Object?> get props => [path, newName];
}

class CopyFile extends FileManagementEvent {
  final String sourcePath;
  final String destinationPath;

  const CopyFile({required this.sourcePath, required this.destinationPath});

  @override
  List<Object?> get props => [sourcePath, destinationPath];
}

class MoveFile extends FileManagementEvent {
  final String sourcePath;
  final String destinationPath;

  const MoveFile({required this.sourcePath, required this.destinationPath});

  @override
  List<Object?> get props => [sourcePath, destinationPath];
}

// Selection Events
class SelectFile extends FileManagementEvent {
  final String path;

  const SelectFile({required this.path});

  @override
  List<Object?> get props => [path];
}

class UnselectFile extends FileManagementEvent {
  final String path;

  const UnselectFile({required this.path});

  @override
  List<Object?> get props => [path];
}

class SelectAllFiles extends FileManagementEvent {
  const SelectAllFiles();
}

class ClearSelection extends FileManagementEvent {
  const ClearSelection();
}

class ToggleFileSelection extends FileManagementEvent {
  final String path;

  const ToggleFileSelection({required this.path});

  @override
  List<Object?> get props => [path];
}

// Favorites and Tags Events
class AddToFavorites extends FileManagementEvent {
  final String path;

  const AddToFavorites({required this.path});

  @override
  List<Object?> get props => [path];
}

class RemoveFromFavorites extends FileManagementEvent {
  final String path;

  const RemoveFromFavorites({required this.path});

  @override
  List<Object?> get props => [path];
}

class AddTag extends FileManagementEvent {
  final String path;
  final String tag;

  const AddTag({required this.path, required this.tag});

  @override
  List<Object?> get props => [path, tag];
}

class RemoveTag extends FileManagementEvent {
  final String path;
  final String tag;

  const RemoveTag({required this.path, required this.tag});

  @override
  List<Object?> get props => [path, tag];
}

// Filter and Sort Events
class ApplyFilter extends FileManagementEvent {
  final FileFilter filter;

  const ApplyFilter({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class ClearFilter extends FileManagementEvent {
  const ClearFilter();
}

class ChangeSortOrder extends FileManagementEvent {
  final SortBy sortBy;
  final SortOrder sortOrder;

  const ChangeSortOrder({required this.sortBy, required this.sortOrder});

  @override
  List<Object?> get props => [sortBy, sortOrder];
}

// View Events
class ChangeViewMode extends FileManagementEvent {
  final ViewMode viewMode;

  const ChangeViewMode({required this.viewMode});

  @override
  List<Object?> get props => [viewMode];
}

class ToggleShowHidden extends FileManagementEvent {
  const ToggleShowHidden();
}

// Permission Events
class RequestPermissions extends FileManagementEvent {
  const RequestPermissions();
}

class CheckPermissions extends FileManagementEvent {
  const CheckPermissions();
}

enum ViewMode { list, grid, tiles }
